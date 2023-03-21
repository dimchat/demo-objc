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
//  DIMUploadTask.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/12.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

#import <DIMP/DIMFileTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Upload Request
 *  ~~~~~~~~~~~~~~
 *  waiting task
 *
 *  properties:
 *      url      - upload API
 *      path     - temporary file path
 *      secret   - authentication key
 *      name     - form var name ('avatar' or 'file')
 *      sender   - message sender
 *      delegate - callback
 */
@interface DIMUploadRequest : DIMFileTransferTask

@property(nonatomic, readonly) NSData *secret;  // authentication algorithm: hex(md5(data + secret + salt))

@property(nonatomic, readonly) const NSString *name;  // form var

@property(nonatomic, readonly) id<MKMID> sender;  // message sender

@property(nonatomic, readonly, weak) id<DIMUploadDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url
                       path:(NSString *)path
                     secret:(NSData *)key
                       name:(const NSString *)var
                     sender:(id<MKMID>)from
                   delegate:(id<DIMUploadDelegate>)callback;

@end

/**
 *  Upload Task
 *  ~~~~~~~~~~~
 *  running task
 *
 *  properties:
 *      url      - remote URL
 *      path     -
 *      secret   -
 *      name     - form var name ('avatar' or 'file')
 *      filename - form file name
 *      data     - form file data
 *      sender   -
 *      delegate - HTTP client
 */
@interface DIMUploadTask : DIMUploadRequest <FSMRunnable>

@property(nonatomic, readonly) NSString *filename;  // file name
@property(nonatomic, readonly) NSData *data;        // file data

- (instancetype)initWithURL:(NSURL *)url
                       name:(const NSString *)var
                   filename:(NSString *)filename
                       data:(NSData *)data
                   delegate:(id<DIMUploadDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
