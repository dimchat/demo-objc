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
//  DIMSharedFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMImmortals.h"
#import "DIMSocialNetworkDatabase.h"

#import "DIMKeyStore+Extension.h"
#import "DIMMessenger+Extension.h"

#import "DIMSharedFacebook.h"

@interface DIMSharedFacebook () {
    
    // ANS
    DIMAddressNameService *_sharedANS;
    
    // Database
    DIMSocialNetworkDatabase *_database;
    
    // Immortals
    MKMImmortals *_immortals;
}

@end

@implementation DIMSharedFacebook

SingletonImplementations(DIMSharedFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // ANS
        _sharedANS = [[DIMAddressNameService alloc] init];
        self.ans = _sharedANS;
        
        _database = [[DIMSocialNetworkDatabase alloc] init];
        
        // Immortal accounts
        _immortals = [[MKMImmortals alloc] init];
        
        DIMMessenger *messenger = [DIMMessenger sharedInstance];
        messenger.barrack = self;
        messenger.keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

#pragma mark - Storage

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_database saveMeta:meta forID:ID];
}

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    DIMMeta *meta = [_database metaForID:ID];
    if (!meta) {
        DIMMessenger *messenger = [DIMMessenger sharedInstance];
        [messenger queryMetaForID:ID];
    }
    return meta;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_database saveProfile:profile];
}

- (nullable DIMProfile *)loadProfileForID:(DIMID *)ID {
    return [_database profileForID:ID];
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
