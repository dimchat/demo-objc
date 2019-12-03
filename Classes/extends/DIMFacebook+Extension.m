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

#import "MKMImmortals.h"
#import "DIMSocialNetworkDatabase.h"

#import "DIMMessenger+Extension.h"

#import "DIMFacebook+Extension.h"

@interface _SharedANS : DIMAddressNameService

@property (weak, nonatomic) DIMSocialNetworkDatabase *database;

+ (instancetype)sharedInstance;

@end

@implementation _SharedANS

SingletonImplementations(_SharedANS, sharedInstance)

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

@interface DIMAddressNameService (Extension)

+ (instancetype)sharedInstance;

@end

@implementation DIMAddressNameService (Extension)

+ (instancetype)sharedInstance {
    return [_SharedANS sharedInstance];
}

@end

#pragma mark -

@interface _SharedFacebook : DIMFacebook {
    
    // Database
    DIMSocialNetworkDatabase *_database;
    
    // Immortals
    MKMImmortals *_immortals;
}

@end

@implementation _SharedFacebook

SingletonImplementations(_SharedFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // ANS
        self.ans = [DIMAddressNameService sharedInstance];
        
        _database = [[DIMSocialNetworkDatabase alloc] init];
        
        // Immortal accounts
        _immortals = [[MKMImmortals alloc] init];
    }
    return self;
}

- (nullable NSArray<DIMID *> *)allUsers {
    return [_database allUsers];
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    return [_database saveUsers:list];
}

#pragma mark Storage

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_database saveMeta:meta forID:ID];
}

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    if ([ID isBroadcast]) {
        // broadcast ID has not meta
        return nil;
    }
    // try from database
    DIMMeta *meta = [_database metaForID:ID];
    if (meta) {
        return meta;
    }
    // try from immortals
    if (MKMNetwork_IsPerson(ID.type)) {
        meta = [_immortals metaForID:ID];
        if (meta) {
            return meta;
        }
    }
    // TODO: check for duplicated querying
    
    // query from DIM network
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    [messenger queryMetaForID:ID];
    return nil;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_database saveProfile:profile];
}

- (nullable DIMProfile *)loadProfileForID:(DIMID *)ID {
    DIMProfile *profile = [_database profileForID:ID];
    BOOL isEmpty = [[profile propertyKeys] count] == 0;
    if (!isEmpty) {
        return profile;
    }
    // try from immortals
    if (MKMNetwork_IsPerson(ID.type)) {
        DIMProfile *tai = [_immortals profileForID:ID];
        if (tai) {
            return tai;
        }
    }
    // TODO: check for duplicated querying
    
    // query from DIM network
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    [messenger queryProfileForID:ID];
    return profile;
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID {
    return [_database savePrivateKey:key forID:ID];
}

- (nullable DIMPrivateKey *)loadPrivateKey:(DIMID *)ID {
    return (DIMPrivateKey *)[_database privateKeyForSignature:ID];
}

- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID {
    return [_database saveContacts:contacts user:ID];
}

- (nullable NSArray<DIMID *> *)loadContacts:(DIMID *)ID {
    return [_database contactsOfUser:ID];
}

- (BOOL)saveMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID {
    return [_database saveMembers:members group:ID];
}

- (nullable NSArray<DIMID *> *)loadMembers:(DIMID *)ID {
    return [_database membersOfGroup:ID];
}

@end

#pragma mark -

@implementation DIMFacebook (Extension)

+ (instancetype)sharedInstance {
    return [_SharedFacebook sharedInstance];
}

- (nullable NSArray<DIMID *> *)allUsers {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    NSAssert(false, @"override me!");
    return NO;
}

@end
