// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMHttpClient.h
//  DIMP
//
//  Created by Albert Moky on 2019/4/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMP/DIMFileTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  HTTP Client
 */
@interface DIMHttpClient : FSMRunner <DIMUploadDelegate, DIMDownloadDelegate>

// @"https://sechat.dim.chat/{ID}/upload?md5={MD5}&salt={SALT}"
@property(nonatomic, strong) NSString *uploadAPI;

@property(nonatomic, strong) NSData *uploadSecret;  // md5(data + secret + salt)

@property(nonatomic, readonly) NSString *avatarDirectory;  // "Library/Caches/.mkm/avatar"
@property(nonatomic, readonly) NSString *cachesDirectory;  // "Library/Caches/.dkd/caches"

@property(nonatomic, readonly) NSString *uploadDirectory;    // "tmp/.dkd/upload"
@property(nonatomic, readonly) NSString *downloadDirectory;  // "tmp/.dkd/download"

+ (instancetype)sharedInstance;

- (void)start;

@end

@interface DIMHttpClient (EncryptedData)

/*
 *  Try to upload encrypted file data for sending file message
 *
 * @param data     - encrypted file data
 * @param filename - filename, format: md5(data) + ext
 * @param from     - sender
 * @return download URL if it's already uploaded before, or just add a task and return nil
 */
- (nullable NSURL *)uploadEncryptedData:(NSData *)data
                               filename:(NSString *)filename
                                 sender:(id<MKMID>)from
                               delegate:(id<DIMUploadDelegate>)delegate;

/**
 *  Try to download encrypted file data for received file message
 *
 * @param url - CDN URL
 * @return file data if it's already downloaded before, or just add a task and return nil
 */
- (nullable NSData *)downloadEncryptedDataFromURL:(NSURL *)url
                                         delegate:(id<DIMDownloadDelegate>)delegate;

@end

@interface DIMHttpClient (Avatar)

- (nullable NSURL *)uploadAvatar:(NSData *)image
                        filename:(NSString *)filename
                          sender:(id<MKMID>)from
                        delegate:(id<DIMUploadDelegate>)delegate;

- (nullable NSData *)downloadAvatarFromURL:(NSURL *)url
                                  delegate:(id<DIMDownloadDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
