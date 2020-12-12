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

- (BOOL)saveANSRecord:(id<MKMID>)ID forName:(NSString *)name {
    return [_ansTable saveRecord:ID forName:name];
}

- (id<MKMID>)ansRecordForName:(NSString *)name {
    return [_ansTable recordForName:name];
}

- (NSArray<NSString *> *)namesWithANSRecord:(NSString *)ID {
    return [_ansTable namesWithRecord:ID];
}

- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key forID:(id<MKMID>)ID {
    //return [key saveKeyWithIdentifier:ID.address];
    return NO;
}

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    return [_metaTable saveMeta:meta forID:ID];
}

- (BOOL)saveDocument:(id<MKMDocument>)profile {
    return [_profileTable saveDocument:profile];
}

- (nullable NSArray<id<MKMID>> *)allUsers {
    return [_userTable allUsers];
}

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list {
    return [_userTable saveUsers:list];
}

- (BOOL)saveUser:(id<MKMID>)user {
    NSMutableArray<id<MKMID>> *list = (NSMutableArray<id<MKMID>> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if ([list containsObject:user]) {
        //NSAssert(false, @"user already exists: %@", user);
        return YES;
    }
    [list addObject:user];
    return [self saveUsers:list];
}

- (BOOL)removeUser:(id<MKMID>)user {
    NSMutableArray<id<MKMID>> *list = (NSMutableArray<id<MKMID>> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if (![list containsObject:user]) {
        //NSAssert(false, @"user not exists: %@", user);
        return YES;
    }
    [list removeObject:user];
    return [self saveUsers:list];
}

- (BOOL)saveContacts:(NSArray *)contacts user:(id<MKMID>)user {
    return [_userTable saveContacts:contacts user:user];
}

- (BOOL)saveMembers:(NSArray *)members group:(id<MKMID>)group {
    return [_groupTable saveMembers:members group:group];
}

#pragma mark -

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    return [_metaTable metaForID:ID];
}

- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                              type:(nullable NSString *)type {
    return [_profileTable documentForID:ID type:type];
}

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    return [_userTable contactsOfUser:user];
}

- (nullable NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    // return nil to use [visa.key, meta.key]
    return nil;
}

- (NSArray<id<MKMPrivateKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    id<MKMPrivateKey>key = nil;//[MKMRSAPrivateKey loadKeyWithIdentifier:user.address];
    return [[NSArray alloc] initWithObjects:key, nil];
}

- (id<MKMPrivateKey>)privateKeyForSignature:(id<MKMID>)user {
    return nil;//[DIMPrivateKey loadKeyWithIdentifier:user.address];
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    return [self privateKeyForSignature:user];
}


- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    id<MKMID>founder = [_groupTable founderOfGroup:group];
    if (founder) {
        return founder;
    }
    // check each member's public key with group meta
    id<MKMMeta>gMeta = [self metaForID:group];
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    id<MKMMeta>meta;
    for (id<MKMID>member in members) {
        // if the user's public key matches with the group's meta,
        // it means this meta was generate by the user's private key
        meta = [self metaForID:member];
        if ([gMeta matchPublicKey:meta.key]) {
            return member;
        }
    }
    return nil;
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    id<MKMID>owner = [_groupTable ownerOfGroup:group];
    if (owner) {
        return owner;
    }
    if ([group type] == MKMNetwork_Polylogue) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    return nil;
}

- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    return [_groupTable membersOfGroup:group];
}

@end
