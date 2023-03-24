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
//  DIMFileTask.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/17.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMFileTask.h"

static const NSTimeInterval TASK_EXPIRES = 300.0;

@interface DIMFileTransferTask () {
    
    NSTimeInterval _lastActive;
    NSInteger _flag;
}

@property(nonatomic, strong) NSURL *url;      // remote URL
@property(nonatomic, strong) NSString *path;  // local path

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation DIMFileTransferTask

- (instancetype)initWithURL:(NSURL *)url path:(NSString *)path {
    if (self = [super init]) {
        self.url = url;
        self.path = path;
        self.session = nil;
        _lastActive = 0;
        _flag = 0;
    }
    return self;
}

- (void)touch {
    _lastActive = OKGetCurrentTimeInterval();
}

- (DIMFileTransferStatus)status {
    if (_lastActive >= 1) {  // > 0
        // task started, check for expired
        NSTimeInterval now = OKGetCurrentTimeInterval();
        NSTimeInterval expired = _lastActive + TASK_EXPIRES;
        if (now > expired) {
            // TODO: send it again?
            return DIMFileTransferExpired;
        }
    }
    if (_flag == -1) {
        return DIMFileTransferError;
    } else if (_flag == 1) {
        return DIMFileTransferSuccess;
    } else if (_flag == 2) {
        return DIMFileTransferFinished;
    } else if (_lastActive < 1) {  // == 0
        return DIMFileTransferWaiting;
    } else {
        return DIMFileTransferRunning;
    }
}

- (void)onError {
    NSAssert(_flag == 0, @"flag updated before");
    _flag = -1;
}

- (void)onSuccess {
    NSAssert(_flag == 0, @"flag updated before");
    _flag = 1;
}

- (void)onFinished {
    NSAssert(_flag == -1 || _flag == 1, @"flag error: %ld", _flag);
    _flag = 2;
}

// "DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
- (NSString *)userAgent {
    // TODO: generate User-Agent
    return nil;
}

// private
- (NSURLSessionConfiguration *)sessionConfiguration {
    NSURLSessionConfiguration *config;
    config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 32.0f;
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;

    NSString *userAgent = [self userAgent];
    if ([userAgent length] > 0) {
        config.HTTPAdditionalHeaders = @{
            @"User-Agent": userAgent,
        };
    }
    return config;
}

// private
- (NSURLSession *)urlSession {
    if (!_session) {
        NSURLSessionConfiguration *config = [self sessionConfiguration];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:queue];
    }
    return _session;
}

@end

#pragma mark URL

static NSString * const chars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=";

NSURL *NSURLFromString(NSString *string) {
    static NSCharacterSet *set;
    OKSingletonDispatchOnce(^{
        set = [NSCharacterSet characterSetWithCharactersInString:chars];
    });
    string = [string stringByAddingPercentEncodingWithAllowedCharacters:set];
    return [NSURL URLWithString:string];
}

NSString *NSStringFromURL(NSURL *url) {
    NSString *str = [url isFileURL] ? [url path] : [url absoluteString];
    return [str stringByRemovingPercentEncoding];
}
