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
//  DIMFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMAddressNameService.h"

#import "DIMFacebook.h"

#define PROFILE_EXPIRES  3600

typedef NSMutableArray<DIMID *> IDList;
typedef NSMutableDictionary<DIMID *, IDList *> IDTable;
typedef NSMutableDictionary<DIMID *, DIMPrivateKey *> KeyTable;
typedef NSMutableDictionary<DIMID *, DIMProfile *> ProfileTable;

@interface DIMFacebook () {
    
    KeyTable     *_privateKeyMap;
    ProfileTable *_profileMap;
    IDTable      *_contactsMap;
    IDTable      *_membersMap;
}

@end

@implementation DIMFacebook

- (instancetype)init {
    if (self = [super init]) {
        // memory caches
        _privateKeyMap = [[KeyTable alloc] init];
        _profileMap    = [[ProfileTable alloc] init];
        _contactsMap   = [[IDTable alloc] init];
        _membersMap    = [[IDTable alloc] init];
    }
    return self;
}

- (nullable DIMID *)ansGet:(NSString *)name {
    return [_ans IDWithName:name];
}

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address {
    DIMID *ID = [[DIMID alloc] initWithAddress:address];
    DIMMeta *meta = [self metaForID:ID];
    if (!meta) {
        // failed to get meta for this ID
        return nil;
    }
    NSString *seed = [meta seed];
    if ([seed length] == 0) {
        return ID;
    }
    ID = [[DIMID alloc] initWithName:seed address:address];
    [self cacheID:ID];
    return ID;
}

#pragma mark DIMBarrack

- (DIMID *)createID:(NSString *)string {
    // try ANS record
    DIMID *ID = [self ansGet:string];
    if (ID) {
        return ID;
    }
    // create by Barrack
    return [super createID:string];
}

- (DIMUser *)createUser:(DIMID *)ID {
    if ([ID isBroadcast]) {
        // create user 'anyone@anywhere'
        return [[DIMUser alloc] initWithID:ID];
    }
    NSAssert([self metaForID:ID], @"failed to get meta for user: %@", ID);
    MKMNetworkType type = ID.type;
    if (MKMNetwork_IsPerson(type)) {
        return [[DIMUser alloc] initWithID:ID];
    }
    if (MKMNetwork_IsRobot(type)) {
        return [[DIMRobot alloc] initWithID:ID];
    }
    if (MKMNetwork_IsStation(type)) {
        return [[DIMStation alloc] initWithID:ID];
    }
    NSAssert(false, @"Unsupported user type: %d", type);
    return nil;
}

- (DIMGroup *)createGroup:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if ([ID isBroadcast]) {
        // create group 'everyone@everywhere'
        return [[DIMGroup alloc] initWithID:ID];
    }
    NSAssert([self metaForID:ID], @"failed to get meta for group: %@", ID);
    MKMNetworkType type = ID.type;
    if (type == MKMNetwork_Polylogue) {
        return [[DIMPolylogue alloc] initWithID:ID];
    }
    if (type == MKMNetwork_Chatroom) {
        return [[DIMChatroom alloc] initWithID:ID];
    }
    if (MKMNetwork_IsProvider(type)) {
        return [[DIMServiceProvider alloc] initWithID:ID];
    }
    NSAssert(false, @"Unsupported group type: %d", type);
    return nil;
}

#pragma mark - MKMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    DIMMeta *meta = [super metaForID:ID];
    if (meta) {
        return meta;
    }
    // load from local storage
    meta = [self loadMetaForID:ID];
    if (meta) {
        [self cacheMeta:meta forID:ID];
    }
    return meta;
}

- (nullable __kindof DIMProfile *)profileForID:(MKMID *)ID {
    DIMProfile *profile = [_profileMap objectForKey:ID];
    if (profile) {
        // check expired time
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval timestamp = [now timeIntervalSince1970] + PROFILE_EXPIRES;
        NSNumber *expires = [profile objectForKey:@"expires"];
        if (!expires) {
            // set expired time
            [profile setObject:@(timestamp) forKey:@"expires"];
            return profile;
        } else if ([expires doubleValue] < timestamp) {
            // not expired yet
            return profile;
        }
    }
    // load from local storage
    profile = [self loadProfileForID:ID];
    if (profile) {
        [self cacheProfile:profile forID:ID];
    }
    return profile;
}

#pragma mark - MKMUserDataSource

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsUser(user.type), @"user ID error: %@", user);
    NSArray<DIMID *> *contacts = [_contactsMap objectForKey:user];
    if (contacts) {
        return contacts;
    }
    // load from local storage
    contacts = [self loadContacts:user];
    if (contacts) {
        [self cacheContacts:contacts user:user];
    }
    return contacts;
}

- (nullable DIMPrivateKey *)privateKeyForSignature:(DIMID *)user {
    NSAssert(MKMNetwork_IsUser(user.type), @"user ID error: %@", user);
    DIMPrivateKey *key = [_privateKeyMap objectForKey:user];
    if (key) {
        return key;
    }
    // load from local storage
    key = [self loadPrivateKey:user];
    if (key) {
        [self cachePrivateKey:key user:user];
    }
    return key;
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryption:(DIMID *)user {
    NSAssert(MKMNetwork_IsUser(user.type), @"user ID error: %@", user);
    NSMutableArray<DIMPrivateKey *> *keys;
    keys = [[NSMutableArray alloc] initWithCapacity:1];
    DIMPrivateKey *key = [_privateKeyMap objectForKey:user];
    if (key) {
        // TODO: support profile.key
        NSAssert([key conformsToProtocol:@protocol(MKMDecryptKey)], @"key error: %@", key);
        [keys addObject:key];
    }
    return keys;
}

#pragma mark - MKMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    DIMID *founder = [super founderOfGroup:group];
    if (founder) {
        return founder;
    }
    // check each member's public key with group meta
    DIMMeta *gMeta = [self metaForID:group];
    if (!gMeta) {
        NSAssert(false, @"failed to get group meta");
        return nil;
    }
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    DIMMeta *mMeta;
    for (DIMID *item in members) {
        NSAssert(MKMNetwork_IsUser(item.type), @"member ID error: %@", item);
        mMeta = [self metaForID:item];
        if (!mMeta) {
            // failed to get member meta
            continue;
        }
        if ([mMeta matchPublicKey:gMeta.key]) {
            // got it!
            return item;
        }
    }
    // TODO: load founder from database
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    DIMID *owner = [super ownerOfGroup:group];
    if (owner) {
        return owner;
    }
    // check group type
    if (group.type == MKMNetwork_Polylogue) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    // TODO: load owner from database
    return nil;
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    // get from cache
    NSArray<DIMID *> *members = [_membersMap objectForKey:group];
    if (!members) {
        // get from barrack
        members = [super membersOfGroup:group];
        if (!members) {
            // load from local storage
            members = [self loadMembers:group];
        }
        if (members) {
            [self cacheMembers:members group:group];
        }
    }
    return members;
}

@end

@implementation DIMFacebook (Storage)

#pragma mark Meta

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if (![self verifyMeta:meta forID:ID]) {
        return NO;
    }
    return [super cacheMeta:meta forID:ID];
}

- (BOOL)verifyMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    NSAssert([meta isValid], @"meta error: %@", meta);
    return [meta matchID:ID];
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark Profile

- (BOOL)cacheProfile:(DIMProfile *)profile forID:(DIMID *)ID {
    NSAssert([ID isValid], @"ID error: %@", ID);
    if (!profile) {
        // remove from cache if exists
        [_profileMap removeObjectForKey:ID];
        return NO;
    }
    if (![self verifyProfile:profile forID:ID]) {
        // profile not valid
        return NO;
    }
    [_profileMap setObject:profile forKey:ID];
    return YES;
}

- (BOOL)cacheProfile:(DIMProfile *)profile {
    NSAssert(profile, @"profile should not be empty");
    DIMID *ID = [self IDWithString:profile.ID];
    return [self cacheProfile:profile forID:ID];
}

- (BOOL)verifyProfile:(DIMProfile *)profile forID:(DIMID *)ID {
    if (![ID isEqual:profile.ID]) {
        // profile ID not match
        return NO;
    }
    return [self verifyProfile:profile];
}

- (BOOL)verifyProfile:(DIMProfile *)profile {
    DIMID *ID = [self IDWithString:profile.ID];
    if (![ID isValid]) {
        NSAssert(false, @"profile ID error: %@", profile);
        return NO;
    }
    // NOTICE: if this is a user profile,
    //             verify it with the user's meta.key
    //         else if this is a polylogue profile,
    //             verify it with the founder's meta.key
    //             (which equals to the group's meta.key)
    DIMMeta *meta;
    if (MKMNetwork_IsGroup(ID.type)) {
        // polylogue?
        if (ID.type == MKMNetwork_Polylogue) {
            meta = [self metaForID:ID];
            if ([profile verify:meta.key]) {
                return YES;
            }
        }
        // check by each member
        NSArray<DIMID *> *members = [self membersOfGroup:ID];
        for (DIMID *item in members) {
            meta = [self metaForID:item];
            if (!meta) {
                // FIXME: meta not found for this member
                continue;
            }
            if ([profile verify:meta.key]) {
                return YES;
            }
        }
        // TODO: what to do about assistants?
        
        // check by owner
        DIMID *owner = [self ownerOfGroup:ID];
        if (owner && [members containsObject:owner]) {
            // already checked
            return NO;
        }
        meta = [self metaForID:owner];
    } else {
        NSAssert(MKMNetwork_IsUser(ID.type), @"profile ID error: %@", ID);
        meta = [self metaForID:ID];
    }
    return [profile verify:meta.key];
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    NSAssert(false, @"override me!");
    return NO;
}

- (nullable DIMProfile *)loadProfileForID:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark Private Key

- (BOOL)cachePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID {
    NSAssert(MKMNetwork_IsUser(ID.type), @"user ID error: %@", ID);
    if (key) {
        [_privateKeyMap setObject:key forKey:ID];
        return YES;
    } else {
        [_privateKeyMap removeObjectForKey:ID];
        return NO;
    }
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (nullable DIMPrivateKey *)loadPrivateKey:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark User Contacts

- (BOOL)cacheContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID {
    NSAssert(MKMNetwork_IsUser(ID.type), @"user ID error: %@", ID);
    if ([contacts count] == 0) {
        [_contactsMap removeObjectForKey:ID];
        return NO;
    } else if ([contacts isKindOfClass:[IDList class]]) {
        [_contactsMap setObject:(IDList *)contacts forKey:ID];
        return YES;
    } else {
        IDList *list = [contacts mutableCopy];
        [_contactsMap setObject:list forKey:ID];
        return YES;
    }
}

- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (nullable NSArray<DIMID *> *)loadContacts:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark Group Members

- (BOOL)cacheMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if ([members count] == 0) {
        [_membersMap removeObjectForKey:ID];
        return NO;
    } else if ([members isKindOfClass:[IDList class]]) {
        [_membersMap setObject:(IDList *)members forKey:ID];
        return YES;
    } else {
        IDList *list = [members mutableCopy];
        [_membersMap setObject:list forKey:ID];
        return YES;
    }
}

- (BOOL)saveMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (nullable NSArray<DIMID *> *)loadMembers:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

@end

@implementation DIMFacebook (Relationship)

- (BOOL)user:(DIMID *)user hasContact:(DIMID *)contact{
    NSArray<DIMID *> *contacts = [self contactsOfUser:user];
    return [contacts containsObject:contact];
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
    [(IDList *)contacts addObject:contact];
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
    [(IDList *)contacts removeObject:contact];
    return [self saveContacts:contacts user:user];
}

#pragma mark -

- (BOOL)group:(DIMID *)group isFounder:(DIMID *)member {
    // check member's public key with group's meta.key
    DIMMeta *gMeta = [self metaForID:group];
    NSAssert(gMeta, @"failed to get meta for group: %@", group);
    DIMMeta *mMeta = [self metaForID:member];
    NSAssert(mMeta, @"failed to get meta for member: %@", member);
    return [gMeta matchPublicKey:mMeta.key];
}

- (BOOL)group:(DIMID *)group isOwner:(DIMID *)member {
    if (group.type == MKMNetwork_Polylogue) {
        return [self group:group isFounder:member];
    }
    NSAssert(false, @"only Polylogue so far: %@", group);
    return NO;
}

- (BOOL)group:(DIMID *)group hasMember:(DIMID *)member {
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    return [members containsObject:member];
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
    [(IDList *)members addObject:member];
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
    [(IDList *)members removeObject:member];
    return [self saveMembers:members group:group];
}

#pragma mark Group Assistants

- (nullable NSArray<DIMID *> *)assistantsOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    DIMID *assistant = [self IDWithString:@"assistant"];
    if ([assistant isValid]) {
        return @[assistant];
    } else {
        return nil;
    }
}

- (BOOL)group:(DIMID *)group hasAssistant:(DIMID *)assistant {
    NSArray<DIMID *> *assistants = [self assistantsOfGroup:group];
    return [assistants containsObject:assistant];
}

@end
