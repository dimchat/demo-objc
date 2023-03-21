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
//  DIMDownloadTask.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/12.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMP/DIMFileTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Download Request
 *  ~~~~~~~~~~~~~~~~
 *  waiting task
 *
 *  properties:
 *      url      - remote URL
 *      path     - temporary file path
 *      delegate - callback
 */
@interface DIMDownloadRequest : DIMFileTransferTask

@property(nonatomic, readonly, weak) id<DIMDownloadDelegate> delegate;

/*
 *  Download data from the URL and save content into the cachePath
 *
 * @param url      - download URL
 * @param path     - temporary file to write data
 * @param delegate - callback
 */
- (instancetype)initWithURL:(NSURL *)url
                       path:(NSString *)path
                   delegate:(id<DIMDownloadDelegate>)delegate
NS_DESIGNATED_INITIALIZER;

@end

/**
 *  Download Task
 *  ~~~~~~~~~~~~~
 *  running task
 *
 *  properties:
 *      url      - remote URL
 *      path     - temporary file path
 *      delegate - HTTP client
 */
@interface DIMDownloadTask : DIMDownloadRequest <FSMRunnable>

@end

NS_ASSUME_NONNULL_END
