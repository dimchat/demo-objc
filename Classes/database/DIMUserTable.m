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
//  DIMUserTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"

#import "DIMClientConstants.h"
#import "DIMUserTable.h"

typedef NSMutableDictionary<id<MKMID>, NSArray *> CacheTableM;

@interface DIMUserTable () {
    
    CacheTableM *_caches;
    
    NSMutableArray<id<MKMID>> *_users;
}

@end

@implementation DIMUserTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
        
        _users = nil;
    }
    return self;
}

/**
 *  Get users filepath in Documents Directory
 *
 * @return "Documents/.dim/users.plist"
 */
- (NSString *)_usersFilePath {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".dim"];
    return [dir stringByAppendingPathComponent:@"users.plist"];
}

- (nullable NSArray<id<MKMID>> *)allUsers {
    if (_users) {
        return _users;
    }
    _users = [[NSMutableArray alloc] init];
    id<MKMID> ID;
    
    NSString *path = [self _usersFilePath];
    NSLog(@"loading users: %@", path);
    NSArray *array = [self arrayWithContentsOfFile:path];
    for (NSString *item in array) {
        ID = MKMIDParse(item);
        [_users addObject:ID];
    }
    
    return _users;
}

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list {
    // update cache
    _users = [list mutableCopy];
    // save into storage
    NSString *path = [self _usersFilePath];
    NSLog(@"saving %ld user(s): %@", list.count, path);
    return [self array:MKMIDRevert(list) writeToFile:path];
}

/**
 *  Get contacts filepath in Documents Directory
 *
 * @param ID - user ID
 * @return "Documents/.mkm/{address}/contacts.plist"
 */
- (NSString *)_filePathWithID:(id<MKMID>)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:[ID.address string]];
    return [dir stringByAppendingPathComponent:@"contacts.plist"];
}

- (nullable NSArray<id<MKMID>> *)_loadContactsForUser:(id<MKMID>)user {
    NSString *path = [self _filePathWithID:user];
    NSArray *array = [self arrayWithContentsOfFile:path];
    if (!array) {
        NSLog(@"contacts not found: %@", path);
        return nil;
    }
    NSLog(@"contacts from %@", path);
    return MKMIDConvert(array);
}

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSArray<id<MKMID>> *contacts = [_caches objectForKey:user];
    if (!contacts) {
        contacts = [self _loadContactsForUser:user];
        if (contacts) {
            // cache it
            [_caches setObject:contacts forKey:user];
        }
    }
    return contacts;
}

- (BOOL)saveContacts:(NSArray *)contacts user:(id<MKMID>)user {
    NSAssert(contacts, @"contacts cannot be empty");
    // update cache
    [_caches setObject:contacts forKey:user];
    
    NSString *path = [self _filePathWithID:user];
    NSLog(@"saving contacts into: %@", path);
    BOOL result = [self array:MKMIDRevert(contacts) writeToFile:path];
    
    if(result){
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kNotificationName_ContactsUpdated object:self
                        userInfo:@{@"ID":user}];
    }
    
    return result;
}

@end
