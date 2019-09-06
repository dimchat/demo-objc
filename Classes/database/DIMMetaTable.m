//
//  DIMMetaTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaTable.h"

//typedef NSMutableDictionary<DIMID *, DIMMeta *> CacheTableM;
//
//@interface DIMMetaTable () {
//
//    CacheTableM *_caches;
//}
//
//@end

@implementation DIMMetaTable

//- (instancetype)init {
//    if (self = [super init]) {
//        _caches = [[CacheTableM alloc] init];
//    }
//    return self;
//}

/**
 *  Get meta filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/meta.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

//- (BOOL)_cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID {
//    if (![meta matchID:ID]) {
//        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
//        return NO;
//    }
//    [_caches setObject:meta forKey:ID];
//    return YES;
//}

- (nullable DIMMeta *)_loadMetaForID:(DIMID *)ID {
    NSString *path = [self _filePathWithID:ID];
    NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
    if (!dict) {
        NSLog(@"meta not found: %@", path);
        return nil;
    }
    NSLog(@"meta from: %@", path);
    return MKMMetaFromDictionary(dict);
}

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
//    DIMMeta *meta = [_caches objectForKey:ID];
//    if (meta) {
//        return meta;
//    }
    DIMMeta *meta = [self _loadMetaForID:ID];
//    if (meta) {
//        // no need to check meta again
//        [_caches setObject:meta forKey:ID];
//    }
    return meta;
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
//    if (![self _cacheMeta:meta forID:ID]) {
//        NSAssert(false, @"failed to cache meta for ID: %@, %@", ID, meta);
//        return NO;
//    }
    NSString *path = [self _filePathWithID:ID];
    if ([self fileExistsAtPath:path]) {
        NSLog(@"meta already exists: %@", path);
        return YES;
    }
    NSLog(@"saving meta into: %@", path);
    return [self dictionary:meta writeToBinaryFile:path];
}

@end
