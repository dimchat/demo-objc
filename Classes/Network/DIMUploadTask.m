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
//  DIMUploadTask.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/12.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

#import "DIMUploadTask.h"

//-------- HTTP --------
#define C_BOUNDARY              "BU1kUJ19yLYPqv5xoT3sbKYbHwjUu1JU7roix"
#define C_CONTENT_TYPE          "multipart/form-data; boundary=" C_BOUNDARY
#define C_BOUNDARY_BEGIN        "--" C_BOUNDARY "\r\n"                         \
                "Content-Disposition: form-data; name=%@; filename=%@\r\n"     \
                "Content-Type: application/octet-stream\r\n\r\n"
#define C_BOUNDARY_END          "\r\n--" C_BOUNDARY "--"

#define C_STRING(S)     [NSString stringWithCString:(S)                        \
                                           encoding:NSUTF8StringEncoding]

#define CONTENT_TYPE    C_STRING(C_CONTENT_TYPE)
#define BOUNDARY_BEGIN  C_STRING(C_BOUNDARY_BEGIN)
#define BOUNDARY_END    C_STRING(C_BOUNDARY_END)

static inline NSData *http_body(const NSString *var, NSString *filename, NSData *data) {
    NSString *begin = [NSString stringWithFormat:BOUNDARY_BEGIN, var, filename];
    NSString *end = BOUNDARY_END;
    
    NSUInteger len = [begin length] + [data length] + [end length];
    NSMutableData *body = [[NSMutableData alloc] initWithCapacity:len];
    [body appendData:MKMUTF8Encode(begin)];
    [body appendData:data];
    [body appendData:MKMUTF8Encode(end)];
    return body;
}

static inline NSURLRequest *http_request(NSURL *url) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    return request;
}
//-------- HTTP --------

@interface DIMUploadTask ()

@property(nonatomic, strong) const NSString *name;  // variable name in form

@property(nonatomic, weak) id<DIMUploadDelegate> delegate;

@property(nonatomic, strong) NSURLSessionUploadTask *sessionTask;

@end

@implementation DIMUploadTask

- (instancetype)initWithURL:(NSURL *)url
                       path:(NSString *)path
                       name:(const NSString *)name
                   delegate:(id<DIMUploadDelegate>)delegate {
    if (self = [super initWithURL:url path:path]) {
        self.name = name;
        self.delegate = delegate;
        self.sessionTask = nil;
    }
    return self;
}

// private
- (void)post:(NSData *)data filename:(NSString *)filename formVar:(const NSString *)var
         url:(NSURL *)url {
    
    NSURLRequest *request = http_request(url);
    NSData *body = http_body(var, filename, data);
    
    NSURLSession *session = [self urlSession];
    NSURLSessionUploadTask *task;

    // create task
    __weak DIMUploadTask *weakSelf = self;
    task = [session uploadTaskWithRequest:request fromData:body
                        completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
        __strong DIMUploadTask *strongSelf = weakSelf;
        //[strongSelf touch];
        NSLog(@"HTTP upload task complete: %@, %@, %@", res, error, MKMUTF8Decode(data));
        if (error) {
            [strongSelf onError];
            [strongSelf.delegate uploadTask:strongSelf successWithResponse:data];
        } else {
            [strongSelf onSuccess];
            [strongSelf.delegate uploadTask:strongSelf failedWithError:error];
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
    
    NSString *path = [self path];
    NSString *filename = [path lastPathComponent];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];

    // start upload task
    [self post:data filename:filename formVar:self.name url:self.url];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                                didSendBodyData:(int64_t)bytesSent
                                 totalBytesSent:(int64_t)totalBytesSent
                       totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [self touch];
    // upload progress
    float progress = (float)totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"upload progress [%f%%] %lld/%lld byte(s) from %@",
          progress * 100, totalBytesSent, totalBytesExpectedToSend, self.path);
    
    // finished
    if (totalBytesSent == totalBytesExpectedToSend) {
        NSLog(@"task finished: %@", task);
    }
}

@end
