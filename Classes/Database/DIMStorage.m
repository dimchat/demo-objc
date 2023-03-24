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
//  DIMStorage.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>

#import "NSDictionary+Binary.h"

#import "DIMStorage.h"

@implementation DIMStorage

static NSString *s_documentDirectory = nil;

+ (NSString *)documentDirectory {
    OKSingletonDispatchOnce(^{
        if (s_documentDirectory == nil) {
            NSArray *paths;
            paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
            s_documentDirectory = paths.firstObject;
        }
    });
    return s_documentDirectory;
}

static NSString *s_cachesDirectory = nil;

+ (NSString *)cachesDirectory {
    OKSingletonDispatchOnce(^{
        if (s_cachesDirectory == nil) {
            NSArray *paths;
            paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                        NSUserDomainMask, YES);
            s_cachesDirectory = paths.firstObject;
        }
    });
    return s_cachesDirectory;
}

static NSString *s_temporaryDirectory = nil;

+ (NSString *)temporaryDirectory {
    OKSingletonDispatchOnce(^{
        if (s_temporaryDirectory == nil) {
            s_temporaryDirectory = NSTemporaryDirectory();
        }
    });
    return s_temporaryDirectory;
}

@end

@implementation DIMStorage (FileManager)

+ (BOOL)createDirectoryAtPath:(NSString *)directory {
    return [self createDirectoryAtPath:directory error:nil];
}
+ (BOOL)createDirectoryAtPath:(NSString *)directory error:(NSError **)error {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:directory isDirectory:&isDir]) {
        // already exists
        NSAssert(isDir, @"path exists but not a directory: %@", directory);
        return YES;
    }
    return [fm createDirectoryAtPath:directory
         withIntermediateDirectories:YES
                          attributes:nil
                               error:error];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

+ (BOOL)removeItemAtPath:(NSString *)path {
    return [self removeItemAtPath:path error:nil];
}
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ok = [fm fileExistsAtPath:path];
    if (!ok) {
        // file not found
        return YES;
    }
    return [fm removeItemAtPath:path error:error];
}

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return [self moveItemAtPath:srcPath toPath:dstPath error:nil];
}
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
                 error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ok = [fm fileExistsAtPath:srcPath];
    if (!ok) {
        NSLog(@"file not found: %@", srcPath);
        return NO;
    }
    // prepare dir
    NSString *dir = [dstPath stringByDeletingLastPathComponent];
    ok = [DIMStorage createDirectoryAtPath:dir];
    if (!ok) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [fm moveItemAtPath:srcPath toPath:dstPath error:error];
}

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return [self copyItemAtPath:srcPath toPath:dstPath error:nil];
}
+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ok = [fm fileExistsAtPath:srcPath];
    if (!ok) {
        NSLog(@"file not found: %@", srcPath);
        return NO;
    }
    // prepare dir
    NSString *dir = [dstPath stringByDeletingLastPathComponent];
    ok = [DIMStorage createDirectoryAtPath:dir];
    if (!ok) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [fm copyItemAtPath:srcPath toPath:dstPath error:error];
}

@end

@implementation DIMStorage (Serialization)

+ (nullable NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path {
    BOOL ok = [DIMStorage fileExistsAtPath:path];
    if (!ok) {
        NSLog(@"file not found: %@", path);
        return nil;
    }
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (BOOL)dictionary:(NSDictionary *)dict writeToBinaryFile:(NSString *)path {
    // prepare directory
    NSString *dir = [path stringByDeletingLastPathComponent];
    BOOL ok = [DIMStorage createDirectoryAtPath:dir];
    if (!ok) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [dict writeToBinaryFile:path atomically:YES];
}

+ (nullable NSArray *)arrayWithContentsOfFile:(NSString *)path {
    BOOL ok = [DIMStorage fileExistsAtPath:path];
    if (!ok) {
        NSLog(@"file not found: %@", path);
        return nil;
    }
    return [NSArray arrayWithContentsOfFile:path];
}

+ (BOOL)array:(NSArray *)list writeToFile:(NSString *)path {
    // prepare directory
    NSString *dir = [path stringByDeletingLastPathComponent];
    BOOL ok = [DIMStorage createDirectoryAtPath:dir];
    if (!ok) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [list writeToFile:path atomically:YES];
}

+ (nullable NSData *)dataWithContentsOfFile:(NSString *)path {
    BOOL ok = [DIMStorage fileExistsAtPath:path];
    if (!ok) {
        NSLog(@"file not found: %@", path);
        return nil;
    }
    return [NSData dataWithContentsOfFile:path];
}

+ (BOOL)data:(NSData *)data writeToFile:(NSString *)path {
    // prepare directory
    NSString *dir = [path stringByDeletingLastPathComponent];
    BOOL ok = [DIMStorage createDirectoryAtPath:dir];
    if (!ok) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [data writeToFile:path atomically:YES];
}

@end

@implementation DIMStorage (LocalCache)

+ (NSString *)avatarPathWithFilename:(NSString *)filename {
    NSString *dir = [self cachesDirectory];
    NSString *AA = [filename substringWithRange:NSMakeRange(0, 2)];
    NSString *BB = [filename substringWithRange:NSMakeRange(2, 4)];
    return [NSString stringWithFormat:@"%@/avatar/%@/%@/%@", dir, AA, BB, filename];
}

+ (NSString *)cachePathWithFilename:(NSString *)filename {
    NSString *dir = [self cachesDirectory];
    NSString *AA = [filename substringWithRange:NSMakeRange(0, 2)];
    NSString *BB = [filename substringWithRange:NSMakeRange(2, 4)];
    return [NSString stringWithFormat:@"%@/files/%@/%@/%@", dir, AA, BB, filename];
}

+ (NSString *)uploadPathWithFilename:(NSString *)filename {
    NSString *dir = [self temporaryDirectory];
    return [NSString stringWithFormat:@"%@/upload/%@", dir, filename];
}

+ (NSString *)downloadPathWithFilename:(NSString *)filename {
    NSString *dir = [self temporaryDirectory];
    return [NSString stringWithFormat:@"%@/download/%@", dir, filename];
}

+ (void)cleanupDirectory:(NSString *)dir beforeTime:(NSTimeInterval)expired {
    // TODO: Delete expired files in this directory cyclically
}

@end
