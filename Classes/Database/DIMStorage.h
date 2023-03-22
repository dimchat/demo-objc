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
//  DIMStorage.h
//  DIMP
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMStorage : NSObject

// "{HOME}/Documents"
+ (NSString *)documentDirectory;

// "{HOME}/Library/Caches"
+ (NSString *)cachesDirectory;

// "{HOME}/tmp"
+ (NSString *)temporaryDirectory;

@end

@interface DIMStorage (FileManager)

+ (BOOL)createDirectoryAtPath:(NSString *)directory;

+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (BOOL)removeItemAtPath:(NSString *)path;

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

@end

@interface DIMStorage (Serialization)

+ (nullable NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path;
+ (BOOL)dictionary:(NSDictionary *)dict writeToBinaryFile:(NSString *)path;

+ (nullable NSArray *)arrayWithContentsOfFile:(NSString *)path;
+ (BOOL)array:(NSArray *)list writeToFile:(NSString *)path;

+ (nullable NSData *)dataWithContentsOfFile:(NSString *)path;
+ (BOOL)data:(NSData *)data writeToFile:(NSString *)path;

@end

@interface DIMStorage (LocalCache)

/**
 *  Avatar image file path
 *
 * @param filename - image filename: hex(md5(data)) + ext
 * @return "Library/Caches/avatar/{AA}/{BB}/{filename}"
 */
+ (NSString *)avatarPathWithFilename:(NSString *)filename;

/**
 *  Cached file path
 *  (image, audio, video, ...)
 *
 * @param filename - messaged filename: hex(md5(data)) + ext
 * @return "Library/Caches/files/{AA}/{BB}/{filename}"
 */
+ (NSString *)cachePathWithFilename:(NSString *)filename;

/**
 *  Encrypted data file path
 *
 * @param filename - messaged filename: hex(md5(data)) + ext
 * @return "tmp/upload/{filename}"
 */
+ (NSString *)uploadPathWithFilename:(NSString *)filename;

/**
 *  Encrypted data file path
 *
 * @param filename - messaged filename: hex(md5(data)) + ext
 * @return "tmp/download/{filename}"
 */
+ (NSString *)downloadPathWithFilename:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
