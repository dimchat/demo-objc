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
//  DIMFileTask.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/17.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <StarTrek/StarTrek.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DIMFileTransferStatus) {
    DIMFileTransferError = -1,
    DIMFileTransferWaiting,  // initialized
    DIMFileTransferRunning,  // uploading/downloading
    DIMFileTransferSuccess,  // upload/download completed, calling delegates
    DIMFileTransferExpired,  // long time no response
    DIMFileTransferFinished  // task finished
};

/**
 *  Base Task
 */
@interface DIMFileTransferTask : NSObject <NSURLSessionTaskDelegate>

@property(nonatomic, readonly) NSURL *url;      // remote URL
@property(nonatomic, readonly) NSString *path;  // local path

@property(nonatomic, readonly) DIMFileTransferStatus status;

- (instancetype)initWithURL:(NSURL *)url path:(NSString *)path;

// update active time
- (void)touch;

// callbacks
- (void)onError;
- (void)onSuccess;
- (void)onFinished;

// protected
- (NSURLSession *)urlSession;

@end

#pragma mark -

@class DIMUploadRequest;
@class DIMDownloadRequest;

@protocol DIMUploadDelegate <NSObject>

/**
 *  Callback when upload task success
 *
 * @param req - upload task
 * @param url - download URL responded by the server
 */
- (void)uploadTask:(__kindof DIMUploadRequest *)req onSuccess:(NSURL *)url;

/**
 *  Callback when upload task failed
 *
 * @param req - upload task
 * @param e   - error info
 */
- (void)uploadTask:(__kindof DIMUploadRequest *)req onFailed:(NSException *)e;

/**
 *  Callback when upload task error
 *
 * @param req - upload task
 * @param e   - error info
 */
- (void)uploadTask:(__kindof DIMUploadRequest *)req onError:(NSError *)e;

@end

@protocol DIMDownloadDelegate <NSObject>

/**
 *  Callback when download task success
 *
 * @param req  - download task
 * @param path - temporary file path
 */
- (void)downloadTask:(__kindof DIMDownloadRequest *)req onSuccess:(NSString *)path;

/**
 *  Callback when download task failed
 *
 * @param req - download task
 * @param e   - error info
 */
- (void)downloadTask:(__kindof DIMDownloadRequest *)req onFailed:(NSException *)e;

/**
 *  Callback when download task error
 *
 * @param req - download task
 * @param e   - server response
 */
- (void)downloadTask:(__kindof DIMDownloadRequest *)req onError:(NSError *)e;

@end

NS_ASSUME_NONNULL_END
