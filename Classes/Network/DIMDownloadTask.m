// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMDownloadTask.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/12.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

#import "DIMDownloadTask.h"

@interface DIMDownloadRequest ()

@property(nonatomic, weak) id<DIMDownloadDelegate> delegate;

@end

@implementation DIMDownloadRequest

- (instancetype)initWithURL:(NSURL *)url
                       path:(NSString *)path
                   delegate:(id<DIMDownloadDelegate>)delegate {
    if (self = [super initWithURL:url path:path]) {
        self.delegate = delegate;
    }
    return self;
}

// Override
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DIMDownloadRequest class]]) {
        if (self == object) {
            // same object
            return YES;
        }
        DIMDownloadRequest *other = (DIMDownloadRequest *)object;
        return [other.url isEqual:self.url];
    }
    return NO;
}

// Override
- (NSUInteger)hash {
    return [self.url hash];
}

// Override
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ url=\"%@\" path=\"%@\" />",
            [self class], [self url], [self path]];
}

// Override
- (NSString *)debugDescription {
    return [self description];
}

@end

#pragma mark -

@interface DIMDownloadTask ()

@property(nonatomic, strong) NSURLSessionDownloadTask *sessionTask;

@end

@implementation DIMDownloadTask

// private
- (void)get:(NSURL *)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSession *session = [self urlSession];
    NSURLSessionDownloadTask *task;
    
    // create task
    __weak DIMDownloadTask *weakSelf = self;
    task = [session downloadTaskWithRequest:request
                          completionHandler:^(NSURL *loc, NSURLResponse *res, NSError *error) {
        __strong DIMDownloadTask *strongSelf = weakSelf;
        //[strongSelf touch];
        NSLog(@"HTTP download task complete: %@, %@, %@", res, error, loc);
        if (error) {
            // connection error
            [strongSelf onError];
            [strongSelf.delegate downloadTask:strongSelf onError:error];
            [strongSelf onFinished];
            return;
        } else if ([res.MIMEType isEqualToString:@"text/html"]) {
            // server respond error
            NSData *data = [NSData dataWithContentsOfURL:loc];
            NSString *html = MKMUTF8Decode(data);
            NSLog(@"download %@ error: %@", url, html);
            // TODO: get error code
            NSInteger code = 404;
            NSDictionary *info = @{
                @"html": html,
            };
            error = [NSError errorWithDomain:NSNetServicesErrorDomain
                                        code:code
                                    userInfo:info];
            [strongSelf onError];
            [strongSelf.delegate downloadTask:strongSelf onError:error];
            [strongSelf onFinished];
            return;
        }
        // move to caches directory
        NSString *path = self.path;
        NSURL *dst = [NSURL fileURLWithPath:path];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm moveItemAtURL:loc toURL:dst error:&error]) {
            [strongSelf onSuccess];
            [strongSelf.delegate downloadTask:strongSelf onSuccess:path];
        } else {
            [strongSelf onError];
            [strongSelf.delegate downloadTask:strongSelf onError:error];
        }
        [strongSelf onFinished];
    }];
    
    // start task
    [task resume];
    self.sessionTask = task;
}

// Override
- (void)run {
    [self touch];
    
    NSURL *url = [self url];

    // start download task
    [self get:url];
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    [self touch];
    // download progress
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"download progress +%lld [%f%%] %lld/%lld byte(s) from %@", bytesWritten,
          progress * 100, totalBytesWritten, totalBytesExpectedToWrite, self.path);
    
    // finished
    if (totalBytesWritten == totalBytesExpectedToWrite) {
        NSLog(@"task finished: %@", task);
    }
}
@end
