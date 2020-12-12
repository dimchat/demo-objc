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
//  DIMFacebook+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMClientConstants.h"

#import "MKMImmortals.h"
#import "DIMSocialNetworkDatabase.h"

#import "DIMMessenger+Extension.h"

#import "DIMFacebook+Extension.h"

@interface ANS : DIMAddressNameService {
    
    DIMSocialNetworkDatabase *_database;
}

- (instancetype)initWithDatabase:(DIMSocialNetworkDatabase *)db;

@end

@implementation ANS

- (instancetype)initWithDatabase:(DIMSocialNetworkDatabase *)db {
    if (self = [super init]) {
        _database = db;
    }
    return self;
}

- (nullable id<MKMID>)IDWithName:(NSString *)username {
    id<MKMID>ID = [_database ansRecordForName:username];
    if (ID) {
        return ID;
    }
    return [super IDWithName:username];
}

- (nullable NSArray<NSString *> *)namesWithID:(id<MKMID>)ID {
    NSArray<NSString *> *names = [_database namesWithANSRecord:ID.string];
    if (names) {
        return names;
    }
    return [super namesWithID:ID];
}

- (BOOL)saveID:(id<MKMID>)ID withName:(NSString *)username {
    if (![self cacheID:ID withName:username]) {
        // username is reserved
        return NO;
    }
    return [_database saveANSRecord:ID forName:username];
}

@end

#pragma mark - Facebook

@interface _SharedFacebook : DIMFacebook {
    
    // user db
    DIMSocialNetworkDatabase *_database;
    
    // ANS
    id<DIMAddressNameService> _ans;

    // immortal accounts
    MKMImmortals *_immortals;
    
    NSMutableArray<MKMUser *> *_allUsers;
}

@end

@implementation _SharedFacebook

SingletonImplementations(_SharedFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // user db
        _database = [[DIMSocialNetworkDatabase alloc] init];
        
        // ANS
        _ans = [[ANS alloc] initWithDatabase:_database];

        // immortal accounts
        _immortals = [[MKMImmortals alloc] init];
    }
    return self;
}

- (nullable NSArray<MKMUser *> *)localUsers {
    if (!_allUsers) {
        _allUsers = [[NSMutableArray alloc] init];
        NSArray<id<MKMID>> *list = [_database allUsers];
        MKMUser *user;
        for (id<MKMID>item in list) {
            user = [self userWithID:item];
            NSAssert(user, @"failed to get local user: %@", item);
            [_allUsers addObject:user];
        }
    }
    return _allUsers;
}

- (nullable MKMUser *)currentUser {
    return [super currentUser];
}

- (void)setCurrentUser:(MKMUser *)user {
    if (!user) {
        NSAssert(false, @"current user cannot be empty");
        return;
    }
    NSArray<id<MKMID>> *list = [_database allUsers];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:(list.count + 1)];
    [mArray addObject:user.ID];
    for (id<MKMID>item in list) {
        if ([mArray containsObject:item]) {
            continue;
        }
        [mArray addObject:item];
    }
    [_database saveUsers:mArray];
    _allUsers = nil;
}

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list {
    return [_database saveUsers:list];
}

#pragma mark Storage

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    return [_database saveMeta:meta forID:ID];
}

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has not meta
        return nil;
    }
    // try from database
    id<MKMMeta>meta = [_database metaForID:ID];
    if (meta) {
        // is empty?
        if (meta.key) {
            return meta;
        }
    }
    // try from immortals
    if (ID.type == MKMNetwork_Main) {
        meta = [_immortals metaForID:ID];
        if (meta) {
            return meta;
        }
    }
    // query from DIM network
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    [messenger queryMetaForID:ID];
    return nil;
}

- (BOOL)saveDocument:(id<MKMDocument>)profile {
    return [_database saveDocument:profile];
}

#define PROFILE_EXPIRES  3600  // profile expires (1 hour)
#define PROFILE_EXPIRES_KEY @"expires"

- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                              type:(nullable NSString *)type {
    // try from database
    id<MKMDocument>profile = [_database documentForID:ID type:type];
    if (profile) {
        // check expired time
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval timestamp = [now timeIntervalSince1970];
        NSNumber *expires = [profile objectForKey:PROFILE_EXPIRES_KEY];
        if (!expires) {
            // set expired time
            [profile setObject:@(timestamp + PROFILE_EXPIRES) forKey:PROFILE_EXPIRES_KEY];
            // is empty?
            if ([profile.propertyKeys count] > 0) {
                return profile;
            }
        } else if ([expires longValue] > timestamp) {
            // not expired yet
            return profile;
        }
    }
    // try fron immortals
    if (ID.type == MKMNetwork_Main) {
        id<MKMDocument>tai = [_immortals documentForID:ID type:type];
        if (tai) {
            return tai;
        }
    }
    // query from DIM network
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    [messenger queryProfileForID:ID];
    return profile;
}

- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key user:(id<MKMID>)ID {
    return [_database savePrivateKey:key forID:ID];
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    id<MKMSignKey> key = [_database privateKeyForSignature:user];
    if (!key) {
        // try immortals
        key = [_immortals privateKeyForSignature:user];
    }
    return key;
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    NSArray<id<MKMDecryptKey>> *keys = [_database privateKeysForDecryption:user];
    if ([keys count] == 0) {
        // try immortals
        keys = [_immortals privateKeysForDecryption:user];
        if ([keys count] == 0) {
            // DIMP v1.0:
            //     decrypt key and the sign key are the same keys
            id<MKMSignKey> key = [self privateKeyForSignature:user];
            if ([key conformsToProtocol:@protocol(MKMDecryptKey)]) {
                keys = @[(id<MKMDecryptKey>)key];
            }
        }
    }
    return keys;
}

- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)ID {
//    if (![self cacheContacts:contacts user:ID]) {
//        return NO;
//    }
    BOOL OK = [_database saveContacts:contacts user:ID];
    if (OK) {
        NSDictionary *info = @{@"ID": ID};
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kNotificationName_ContactsUpdated
                          object:self userInfo:info];
    }
    return OK;
}

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)ID {
    return [_database contactsOfUser:ID];
}

- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    return [_database membersOfGroup:group];
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)ID {
    BOOL OK = [_database saveMembers:members group:ID];
    if (OK) {
        NSDictionary *info = @{@"group": ID};
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kNotificationName_GroupMembersUpdated
                          object:self userInfo:info];
    }
    return OK;
}

- (nullable NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    return @[
        // dev
        MKMIDFromString(@"assistant@2PpB6iscuBjA15oTjAsiswoX9qis5V3c1Dq"),
        // desktop.dim.chat
        MKMIDFromString(@"assistant@4WBSiDzg9cpZGPqFrQ4bHcq4U5z9QAQLHS"),
    ];
    //return [super assistantsOfGroup:group];
}

@end

#pragma mark -

@implementation DIMFacebook (Extension)

+ (instancetype)sharedInstance {
    return [_SharedFacebook sharedInstance];
}

- (void)setCurrentUser:(MKMUser *)user {
    NSAssert(false, @"implement me!");
}

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key user:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)user:(id<MKMID>)user addContact:(id<MKMID>)contact {
    NSLog(@"user %@ add contact %@", user, contact);
    NSArray<id<MKMID>> *contacts = [self contactsOfUser:user];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            NSLog(@"contact %@ already exists, user: %@", contact, user);
            return NO;
        } else if (![contacts respondsToSelector:@selector(addObject:)]) {
            // mutable
            contacts = [contacts mutableCopy];
        }
    } else {
        contacts = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [(NSMutableArray *)contacts addObject:contact];
    return [self saveContacts:contacts user:user];
}

- (BOOL)user:(id<MKMID>)user removeContact:(id<MKMID>)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
    NSArray<id<MKMID>> *contacts = [self contactsOfUser:user];
    if (contacts) {
        if (![contacts containsObject:contact]) {
            NSLog(@"contact %@ not exists, user: %@", contact, user);
            return NO;
        } else if (![contacts respondsToSelector:@selector(removeObject:)]) {
            // mutable
            contacts = [contacts mutableCopy];
        }
    } else {
        NSLog(@"user %@ doesn't has contact yet", user);
        return NO;
    }
    [(NSMutableArray *)contacts removeObject:contact];
    return [self saveContacts:contacts user:user];
}

- (BOOL)group:(id<MKMID>)group addMember:(id<MKMID>)member {
    NSLog(@"group %@ add member %@", group, member);
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if (members) {
        if ([members containsObject:member]) {
            NSLog(@"member %@ already exists, group: %@", member, group);
            return NO;
        } else if (![members respondsToSelector:@selector(addObject:)]) {
            // mutable
            members = [members mutableCopy];
        }
    } else {
        members = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [(NSMutableArray *)members addObject:member];
    return [self saveMembers:members group:group];
}

- (BOOL)group:(id<MKMID>)group removeMember:(id<MKMID>)member {
    NSLog(@"group %@ remove member %@", group, member);
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if (members) {
        if (![members containsObject:member]) {
            NSLog(@"members %@ not exists, group: %@", member, group);
            return NO;
        } else if (![members respondsToSelector:@selector(removeObject:)]) {
            // mutable
            members = [members mutableCopy];
        }
    } else {
        NSLog(@"group %@ doesn't has member yet", group);
        return NO;
    }
    [(NSMutableArray *)members removeObject:member];
    return [self saveMembers:members group:group];
}

- (nullable NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    id<MKMID> assistant = nil;//[self IDWithString:@"assistant"];
    if (assistant) {
        return @[assistant];
    } else {
        return nil;
    }
}

@end
