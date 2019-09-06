//
//  DIMStorage.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "DIMStorage.h"

@implementation DIMStorage

static NSString *s_document = nil;
- (NSString *)documentDirectory {
    SingletonDispatchOnce(^{
        if (s_document == nil) {
            NSArray *paths;
            paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
            s_document = paths.firstObject;
        }
    });
    return s_document;
}

- (BOOL)createDirectoryAtPath:(NSString *)directory {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:directory isDirectory:&isDir]) {
        // already exists
        NSAssert(isDir, @"path exists but not a directory: %@", directory);
        return YES;
    }
    NSError *error = nil;
    return [fm createDirectoryAtPath:directory
         withIntermediateDirectories:YES
                          attributes:nil
                               error:&error];
}

- (BOOL)fileExistsAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

- (nullable NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path {
    if (![self fileExistsAtPath:path]) {
        // file not found
        return nil;
    }
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

- (BOOL)dictionary:(NSDictionary *)dict writeToBinaryFile:(NSString *)path {
    NSString *dir = [path stringByDeletingLastPathComponent];
    if (![self createDirectoryAtPath:dir]) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [dict writeToBinaryFile:path];
}

- (nullable NSArray *)arrayWithContentsOfFile:(NSString *)path {
    if (![self fileExistsAtPath:path]) {
        // file not found
        return nil;
    }
    return [NSArray arrayWithContentsOfFile:path];
}

- (BOOL)array:(NSArray *)list writeToFile:(NSString *)path {
    NSString *dir = [path stringByDeletingLastPathComponent];
    if (![self createDirectoryAtPath:dir]) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return NO;
    }
    return [list writeToFile:path atomically:YES];
}

@end
