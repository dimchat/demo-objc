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

#import "DIMFileServer.h"

#import "DIMUploadTask.h"

//-------- HTTP Body --------
static const char *BOUNDARY = "BU1kUJ19yLYPqv5xoT3sbKYbHwjUu1JU7roix";
static const char *CONTENT_TYPE = "multipart/form-data; boundary=%@";
static const char *BEGIN = "--%@\r\n"
                "Content-Disposition: form-data; name=%@; filename=%@\r\n"
                "Content-Type: application/octet-stream\r\n\r\n";
static const char *END = "\r\n--%@";

static inline NSString *content_type(void) {
    NSString *format = [NSString stringWithCString:CONTENT_TYPE
                                          encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:format, BOUNDARY];
}

static inline NSString *body_begin(NSString *var, NSString *filename) {
    NSString *format = [NSString stringWithCString:BEGIN
                                          encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:format, BOUNDARY, var, filename];
}
static inline NSString *body_end(void) {
    NSString *format = [NSString stringWithCString:END
                                          encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:format, BOUNDARY];
}

static inline NSData *http_body(NSString *var, NSString *filename, NSData *data) {
    NSString *begin = body_begin(var, filename);
    NSString *end = body_end();
    
    NSUInteger len = [begin length] + [data length] + [end length];
    NSMutableData *body = [[NSMutableData alloc] initWithCapacity:len];
    [body appendData:MKMUTF8Encode(begin)];
    [body appendData:data];
    [body appendData:MKMUTF8Encode(end)];
    return body;
}
//-------- HTTP Body --------

@interface DIMUploadTask ()

@property(nonatomic, strong) NSString *url;  // URL string
@property(nonatomic, strong) NSString *var;  // var name
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) NSData   *data; // file data

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionUploadTask *sessionTask;

@end

@implementation DIMUploadTask

//- (instancetype)init {
//    NSAssert(false, @"DON'T call me");
//    NSString *url = nil;
//    NSString *var = nil;
//    NSString *filename = nil;
//    NSData *data = nil;
//    id<DIMFileServerDelegate> delegate = nil;
//    return [self initWithURL:url
//                         var:var
//                    filename:filename
//                        data:data
//                    delegate:delegate];
//}
//
///* designated initializer */
//- (instancetype)initWithURL:(NSString *)url
//                        var:(NSString *)var
//                   filename:(NSString *)filename
//                       data:(NSData *)data
//                   delegate:(id<DIMFileServerDelegate>)delegate {
//    if (self = [super init]) {
//        self.url = url;
//        self.var = var;
//        self.filename = filename;
//        self.data = data;
//        self.delegate = delegate;
//    }
//    return self;
//}
//
//// Override
//- (BOOL)isEqual:(id)object {
//    if ([object isKindOfClass:[DIMUploadTask class]]) {
//        if (self == object) {
//            // same object
//            return YES;
//        }
//        DIMUploadTask *other = (DIMUploadTask *)object;
//        return [_url isEqualToString:other.url] && [_data isEqualToData:other.data];
//    }
//    return NO;
//}
//
//// Override
//- (NSUInteger)hash {
//    return [_url hash] * 13 + [_data hash];
//}
//
//- (NSURLSession *)urlSession {
//    if (!_urlSession) {
//        NSURLSessionConfiguration *config;
//        config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        config.timeoutIntervalForRequest = 30.0f;
//        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
//        if (_userAgent.length > 0) {
//            config.HTTPAdditionalHeaders = @{@"User-Agent": _userAgent};
//        }
//
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        _urlSession = [NSURLSession sessionWithConfiguration:config
//                                                    delegate:self
//                                               delegateQueue:queue];
//    }
//    return _urlSession;
//}
//
//#pragma mark - NSURLSessionTaskDelegate
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
//
//}
//
//- (void)postToURL:(NSURL *)url
//              var:(NSString *)name
//         filename:(NSString *)filename
//             data:(NSData *)data {
//    // URL request
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    [request setValue:content_type() forKey:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//
//    // HTTP body
//    NSData *body = http_body(name, filename, data);
//
//    // upload task
//    NSURLSession *session = [self urlSession];
//    NSURLSessionUploadTask *task;
//    task = [session uploadTaskWithRequest:request
//                                 fromData:body
//                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        <#code#>
//    }];
//    self.sessionTask = task;
//    [task resume];
//}

@end
