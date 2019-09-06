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

static NSString *s_documentDirectory = nil;

- (NSString *)documentDirectory {
    SingletonDispatchOnce(^{
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

- (NSString *)cachesDirectory {
    SingletonDispatchOnce(^{
        if (s_cachesDirectory == nil) {
            NSArray *paths;
            paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                        NSUserDomainMask, YES);
            s_cachesDirectory = paths.firstObject;
        }
    });
    return s_cachesDirectory;
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

- (BOOL)removeItemAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSError *err = nil;
        [fm removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"failed to remove file: %@", err);
            return NO;
        }
    }
    return YES;
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
