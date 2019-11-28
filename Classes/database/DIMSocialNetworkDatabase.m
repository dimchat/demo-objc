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
//  DIMSocialNetworkDatabase.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMAddressNameTable.h"
#import "DIMMetaTable.h"
#import "DIMProfileTable.h"
#import "DIMUserTable.h"
#import "DIMGroupTable.h"

#import "DIMSocialNetworkDatabase.h"

@interface DIMSocialNetworkDatabase () {
    
    DIMAddressNameTable *_ansTable;
    DIMMetaTable *_metaTable;
    DIMProfileTable *_profileTable;
    DIMUserTable *_userTable;
    DIMGroupTable *_groupTable;
}

@end

@implementation DIMSocialNetworkDatabase

- (instancetype)init {
    if (self = [super init]) {
        _ansTable = [[DIMAddressNameTable alloc] init];
        _metaTable = [[DIMMetaTable alloc] init];
        _profileTable = [[DIMProfileTable alloc] init];
        _userTable = [[DIMUserTable alloc] init];
        _groupTable = [[DIMGroupTable alloc] init];
    }
    return self;
}

- (BOOL)saveANSRecord:(DIMID *)ID forName:(NSString *)name {
    return [_ansTable saveRecord:ID forName:name];
}

- (DIMID *)ansRecordForName:(NSString *)name {
    return [_ansTable recordForName:name];
}

- (NSArray<DIMID *> *)namesWithANSRecord:(NSString *)ID {
    return [_ansTable namesWithRecord:ID];
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID {
    return [key saveKeyWithIdentifier:ID.address];
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_metaTable saveMeta:meta forID:ID];
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_profileTable saveProfile:profile];
}

- (nullable NSArray<DIMID *> *)allUsers {
    return [_userTable allUsers];
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    return [_userTable saveUsers:list];
}

- (BOOL)saveUser:(DIMID *)user {
    NSMutableArray<DIMID *> *list = (NSMutableArray<DIMID *> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if ([list containsObject:user]) {
        //NSAssert(false, @"user already exists: %@", user);
        return YES;
    }
    [list addObject:user];
    return [self saveUsers:list];
}

- (BOOL)removeUser:(DIMID *)user {
    NSMutableArray<DIMID *> *list = (NSMutableArray<DIMID *> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if (![list containsObject:user]) {
        //NSAssert(false, @"user not exists: %@", user);
        return YES;
    }
    [list removeObject:user];
    return [self saveUsers:list];
}

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user {
    return [_userTable saveContacts:contacts user:user];
}

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group {
    return [_groupTable saveMembers:members group:group];
}

#pragma mark -

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    return [_metaTable metaForID:ID];
}

- (nullable __kindof DIMProfile *)profileForID:(DIMID *)ID {
    return [_profileTable profileForID:ID];
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    return [_userTable contactsOfUser:user];
}

- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(nonnull DIMID *)user {
    return nil;
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryption:(DIMID *)user {
    DIMPrivateKey *key = [DIMPrivateKey loadKeyWithIdentifier:user.address];
    return [[NSArray alloc] initWithObjects:key, nil];
}

- (nullable DIMPrivateKey *)privateKeyForSignature:(DIMID *)user {
    return [DIMPrivateKey loadKeyWithIdentifier:user.address];
}

- (nullable NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(nonnull DIMID *)user {
    return nil;
}


- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    DIMID *founder = [_groupTable founderOfGroup:group];
    if ([founder isValid]) {
        return founder;
    }
    // check each member's public key with group meta
    DIMMeta *gMeta = [self metaForID:group];
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    DIMMeta *meta;
    for (DIMID *member in members) {
        // if the user's public key matches with the group's meta,
        // it means this meta was generate by the user's private key
        meta = [self metaForID:member];
        if ([gMeta matchPublicKey:meta.key]) {
            return member;
        }
    }
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    DIMID *owner = [_groupTable ownerOfGroup:group];
    if ([owner isValid]) {
        return owner;
    }
    if ([group type] == MKMNetwork_Polylogue) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    return nil;
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    return [_groupTable membersOfGroup:group];
}

@end
