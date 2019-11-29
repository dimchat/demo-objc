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
//  DIMGroupTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMClientConstants.h"
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

- (nullable NSArray<DIMID *> *)_loadMembersOfGroup:(DIMID *)group {
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
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    NSArray<DIMID *> *members = [_caches objectForKey:group];
    if (!members) {
        members = [self _loadMembersOfGroup:group];
        if (members) {
            // cache it
            [_caches setObject:members forKey:group];
        }
    }
    return members;
}

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    NSAssert(members.count > 0, @"group members cannot be empty");
    // update cache
    [_caches setObject:members forKey:group];
    
    NSString *path = [self _filePathWithID:group];
    NSLog(@"saving members into: %@", path);
    BOOL result = [self array:members writeToFile:path];
    return result;
}

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    return nil;
}

@end
