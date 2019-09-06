//
//  DIMGroupTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMGroupTable.h"

typedef NSMutableDictionary<DIMID *, NSArray *> CacheTableM;

@interface DIMGroupTable () {
    
    CacheTableM *_caches;
}

@end

@implementation DIMGroupTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
    }
    return self;
}

/**
 *  Get group members filepath in Documents Directory
 *
 * @param ID - group ID
 * @return "Documents/.mkm/{address}/members.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"members.plist"];
}

- (nullable NSArray<DIMID *> *)_loadMembersForGroup:(DIMID *)group {
    NSString *path = [self _filePathWithID:group];
    NSArray *array = [self arrayWithContentsOfFile:path];
    if (!array) {
        NSLog(@"members not found: %@", path);
        return nil;
    }
    NSLog(@"members from %@", path);
    NSMutableArray<DIMID *> *members;
    DIMID *ID;
    members = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *item in array) {
        ID = DIMIDWithString(item);
        if (![ID isValid]) {
            NSAssert(false, @"members ID invalid: %@", item);
            continue;
        }
        [members addObject:ID];
    }
    // ensure that founder is at the front
    if (members.count > 1) {
        DIMMeta *gMeta = DIMMetaForID(group);
        DIMPublicKey *PK;
        for (NSUInteger index = 0; index < members.count; ++index) {
            ID = [members objectAtIndex:index];
            PK = [DIMMetaForID(ID) key];
            if ([gMeta matchPublicKey:PK]) {
                if (index > 0) {
                    // move to front
                    [members removeObjectAtIndex:index];
                    [members insertObject:ID atIndex:0];
                }
                break;
            }
        }
    }
    return members;
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSArray<DIMID *> *members = [_caches objectForKey:group];
    if (!members) {
        members = [self _loadMembersForGroup:group];
        if (members) {
            // cache it
            [_caches setObject:members forKey:group];
        }
    }
    return members;
}

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group {
    NSAssert(members.count > 0, @"group members cannot be empty");
    // update cache
    [_caches setObject:members forKey:group];
    
    NSString *path = [self _filePathWithID:group];
    NSLog(@"saving members into: %@", path);
    return [self array:members writeToFile:path];
}

#pragma mark -

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    // check each member's public key with group meta
    DIMMeta *gMeta = DIMMetaForID(group);
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    DIMMeta *meta;
    for (DIMID *member in members) {
        // if the user's public key matches with the group's meta,
        // it means this meta was generate by the user's private key
        meta = DIMMetaForID(member);
        if ([gMeta matchPublicKey:meta.key]) {
            return member;
        }
    }
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    if (group.type == MKMNetwork_Polylogue) {
        // the polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    NSAssert(false, @"group owner not support yet: %@", group);
    return nil;
}

@end
