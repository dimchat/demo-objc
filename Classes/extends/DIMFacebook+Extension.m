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

@interface DIMAddressNameService (Extension)

@property (weak, nonatomic) DIMSocialNetworkDatabase *database;

+ (instancetype)sharedInstance;

@end

@interface _SharedANS : DIMAddressNameService {
    
    DIMSocialNetworkDatabase *_database;
}

+ (instancetype)sharedInstance;

@end

@implementation _SharedANS

SingletonImplementations(_SharedANS, sharedInstance)

- (DIMSocialNetworkDatabase *)database {
    return _database;
}

- (void)setDatabase:(DIMSocialNetworkDatabase *)database {
    _database = database;
}

- (nullable DIMID *)IDWithName:(NSString *)username {
    DIMID *ID = [_database ansRecordForName:username];
    if (ID) {
        return ID;
    }
    return [super IDWithName:username];
}

- (nullable NSArray<NSString *> *)namesWithID:(DIMID *)ID {
    NSArray<NSString *> *names = [_database namesWithANSRecord:ID];
    if (names) {
        return names;
    }
    return [super namesWithID:ID];
}

- (BOOL)saveID:(DIMID *)ID withName:(NSString *)username {
    if (![self cacheID:ID withName:username]) {
        // username is reserved
        return NO;
    }
    return [_database saveANSRecord:ID forName:username];
}

@end

@implementation DIMAddressNameService (Extension)

+ (instancetype)sharedInstance {
    return [_SharedANS sharedInstance];
}

- (DIMSocialNetworkDatabase *)database {
    NSAssert(false, @"override me!");
    return nil;
}

- (void)setDatabase:(DIMSocialNetworkDatabase *)database {
    NSAssert(false, @"override me!");
}

@end

#pragma mark - Facebook

@interface _SharedFacebook : DIMFacebook {
    
    // user db
    DIMSocialNetworkDatabase *_database;
    
    // immortal accounts
    MKMImmortals *_immortals;
    
    NSMutableArray<DIMUser *> *_allUsers;
}

@end

@implementation _SharedFacebook

SingletonImplementations(_SharedFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // user db
        _database = [[DIMSocialNetworkDatabase alloc] init];
        
        // immortal accounts
        _immortals = [[MKMImmortals alloc] init];
        
        // ANS
        DIMAddressNameService *ans = [DIMAddressNameService sharedInstance];
        ans.database = _database;
        self.ans = ans;
    }
    return self;
}

- (nullable NSArray<DIMUser *> *)localUsers {
    if (!_allUsers) {
        _allUsers = [[NSMutableArray alloc] init];
        NSArray<DIMID *> *list = [_database allUsers];
        DIMUser *user;
        for (DIMID *item in list) {
            user = [self userWithID:item];
            NSAssert(user, @"failed to get local user: %@", item);
            [_allUsers addObject:user];
        }
    }
    return _allUsers;
}

- (nullable DIMUser *)currentUser {
    return [super currentUser];
}

- (void)setCurrentUser:(DIMUser *)user {
    if (!user) {
        NSAssert(false, @"current user cannot be empty");
        return;
    }
    NSArray<DIMID *> *list = [_database allUsers];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:(list.count + 1)];
    [mArray addObject:user.ID];
    for (DIMID *item in list) {
        if ([mArray containsObject:item]) {
            continue;
        }
        [mArray addObject:item];
    }
    [_database saveUsers:mArray];
    _allUsers = nil;
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    return [_database saveUsers:list];
}

#pragma mark Storage

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_database saveMeta:meta forID:ID];
}

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    if ([ID isBroadcast]) {
        // broadcast ID has not meta
        return nil;
    }
    // try from database
    DIMMeta *meta = [_database metaForID:ID];
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

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_database saveProfile:profile];
}

#define PROFILE_EXPIRES  3600  // profile expires (1 hour)
#define PROFILE_EXPIRES_KEY @"expires"

- (nullable DIMProfile *)profileForID:(DIMID *)ID {
    // try from database
    DIMProfile *profile = [_database profileForID:ID];
    if (profile) {
        // is empty?
        if ([profile.propertyKeys count] > 0) {
            // check expired time
            NSDate *now = [[NSDate alloc] init];
            NSTimeInterval timestamp = [now timeIntervalSince1970];
            NSNumber *expires = [profile objectForKey:PROFILE_EXPIRES_KEY];
            if (!expires) {
                // set expired time
                [profile setObject:@(timestamp + PROFILE_EXPIRES) forKey:PROFILE_EXPIRES_KEY];
                return profile;
            } else if ([expires longValue] > timestamp) {
                // not expired yet
                return profile;
            }
        }
    }
    // try fron immortals
    if (ID.type == MKMNetwork_Main) {
        DIMProfile *tai = [_immortals profileForID:ID];
        if (tai) {
            return tai;
        }
    }
    // query from DIM network
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    [messenger queryProfileForID:ID];
    return profile;
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID {
    return [_database savePrivateKey:key forID:ID];
}

- (nullable id<DIMSignKey>)privateKeyForSignature:(DIMID *)user {
    NSAssert([user isUser], @"user ID error: %@", user);
    id<DIMSignKey> key = [_database privateKeyForSignature:user];
    if (!key) {
        // try immortals
        key = [_immortals privateKeyForSignature:user];
    }
    return key;
}

- (nullable NSArray<id<DIMDecryptKey>> *)privateKeysForDecryption:(DIMID *)user {
    NSAssert([user isUser], @"user ID error: %@", user);
    NSArray<id<DIMDecryptKey>> *keys = [_database privateKeysForDecryption:user];
    if ([keys count] == 0) {
        // try immortals
        keys = [_immortals privateKeysForDecryption:user];
        if ([keys count] == 0) {
            // DIMP v1.0:
            //     decrypt key and the sign key are the same keys
            id<DIMSignKey> key = [self privateKeyForSignature:user];
            if ([key conformsToProtocol:@protocol(DIMDecryptKey)]) {
                keys = @[(id<DIMDecryptKey>)key];
            }
        }
    }
    return keys;
}

- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID {
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

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)ID {
    return [_database contactsOfUser:ID];
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    return [_database membersOfGroup:group];
}

- (BOOL)saveMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID {
    BOOL OK = [_database saveMembers:members group:ID];
    if (OK) {
        NSDictionary *info = @{@"group": ID};
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kNotificationName_GroupMembersUpdated
                          object:self userInfo:info];
    }
    return OK;
}

@end

#pragma mark -

@implementation DIMFacebook (Extension)

+ (instancetype)sharedInstance {
    return [_SharedFacebook sharedInstance];
}

- (void)setCurrentUser:(DIMUser *)user {
    NSAssert(false, @"override me!");
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)user:(DIMID *)user addContact:(DIMID *)contact {
    NSLog(@"user %@ add contact %@", user, contact);
    NSArray<DIMID *> *contacts = [self contactsOfUser:user];
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

- (BOOL)user:(DIMID *)user removeContact:(DIMID *)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
    NSArray<DIMID *> *contacts = [self contactsOfUser:user];
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

- (BOOL)group:(DIMID *)group addMember:(DIMID *)member {
    NSLog(@"group %@ add member %@", group, member);
    NSArray<DIMID *> *members = [self membersOfGroup:group];
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

- (BOOL)group:(DIMID *)group removeMember:(DIMID *)member {
    NSLog(@"group %@ remove member %@", group, member);
    NSArray<DIMID *> *members = [self membersOfGroup:group];
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

@end
