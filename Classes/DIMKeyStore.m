//
//  DIMKeyStore.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "DIMKeyStore.h"

// "Library/Caches"
static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

@implementation DIMKeyStore

SingletonImplementations(DIMKeyStore, sharedInstance)

- (BOOL)saveKeys:(NSDictionary *)keyMap {
    // "Library/Caches/keystore.plist"
    NSString *dir = caches_directory();
    NSString *path = [dir stringByAppendingPathComponent:@"keystore.plist"];
    return [keyMap writeToBinaryFile:path];
}

- (NSDictionary *)loadKeys {
    NSString *dir = caches_directory();
    NSString *path = [dir stringByAppendingPathComponent:@"keystore.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return nil;
}

@end
