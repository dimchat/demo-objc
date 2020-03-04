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
//  DIMRegister.m
//  DIMClient
//
//  Created by Albert Moky on 2019/12/20.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook+Extension.h"
#import "DIMMessenger+Extension.h"

#import "DIMRegister.h"

@implementation DIMRegister

- (instancetype)init {
    if (self = [super init]) {
        _network = MKMNetwork_Main;
    }
    return self;
}

- (DIMUser *)createUserWithName:(NSString *)nickname avatar:(NSString *)url {
    // 1. generate private key
    [self generatePrivateKey];
    // 2. generate meta
    DIMMeta *meta = [self generateMeta:@"user"];
    // 3. generate ID
    DIMID *ID = [self generateIDWithMeta:meta];
    // 4. generate profile
    DIMProfile *profile = [self createProfileWithID:ID name:nickname avatar:url];
    // 5. save private key, meta & profile in local storage
    //    don't forget to upload them onto the DIM station
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    [facebook saveMeta:meta forID:ID];
    [facebook savePrivateKey:_key user:ID];
    [facebook saveProfile:profile];
    // 6. create user
    return [facebook userWithID:ID];
}

- (DIMGroup *)createGroupWithName:(NSString *)name founder:(DIMID *)ID {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    // 1. get private key
    _key = (DIMPrivateKey *)[facebook privateKeyForSignature:ID];
    // 2. generate meta
    DIMMeta *meta = [self generateMeta:@"group"];
    // 3. generate ID
    DIMID *group = [self generateIDWithMeta:meta network:MKMNetwork_Polylogue];
    // 4. generate profile
    DIMProfile *profile = [self createProfileWithID:group name:name];
    // 5. save meta & profile in local storage
    //    don't forget to upload them onto the DIM station
    [facebook saveMeta:meta forID:group];
    [facebook saveProfile:profile];
    // 6. create group
    return [facebook groupWithID:group];
}

- (DIMPrivateKey *)generatePrivateKey {
    return [self generatePrivateKey:ACAlgorithmRSA];
}

- (DIMPrivateKey *)generatePrivateKey:(NSString *)algorithm {
    return MKMPrivateKeyWithAlgorithm(algorithm);
}

- (DIMMeta *)generateMeta:(NSString *)seed {
    NSAssert(_key, @"private key not set yet");
    return [DIMMeta generateWithVersion:MKMMetaDefaultVersion
                             privateKey:_key
                                   seed:seed];
}

- (DIMID *)generateIDWithMeta:(DIMMeta *)meta {
    return [self generateIDWithMeta:meta network:_network];
}

- (DIMID *)generateIDWithMeta:(DIMMeta *)meta network:(MKMNetworkType)type {
    return [meta generateID:type];
}

- (DIMProfile *)createProfileWithID:(DIMID *)ID name:(NSString *)name {
    return [self createProfileWithID:ID name:name avatar:nil];
}

- (DIMProfile *)createProfileWithID:(DIMID *)ID name:(NSString *)name avatar:(nullable NSString *)url {
    NSAssert([ID isValid], @"ID error: %@", ID);
    NSAssert(_key, @"private key not set yet");
    DIMProfile *profile = [[DIMProfile alloc] initWithID:ID];
    [profile setName:name];
    if (url) {
        NSAssert([ID isUser], @"user ID error: %@", ID);
        [profile setAvatar:url];
    }
    [profile sign:_key];
    return profile;
}

- (DIMProfile *)credateProfileWithID:(DIMID *)ID properties:(NSDictionary *)info {
    NSAssert([ID isValid], @"ID error: %@", ID);
    NSAssert(_key, @"private key not set yet");
    DIMProfile *profile = [[DIMProfile alloc] initWithID:ID];
    for (NSString *name in info) {
        [profile setProperty:[info objectForKey:name] forKey:name];
    }
    [profile sign:_key];
    return profile;
}

- (BOOL)uploadInfoWithID:(DIMID *)ID meta:(DIMMeta *)meta profile:(nullable DIMProfile *)profile {
    NSAssert([ID isValid], @"ID error: %@", ID);
    DIMCommand *cmd;
    if (profile) {
        NSAssert([ID isEqual:profile.ID], @"profile ID not match: %@, %@", ID, profile);
        NSAssert([profile isValid], @"profile not valid: %@", profile);
        cmd = [[DIMProfileCommand alloc] initWithID:ID meta:meta profile:profile];
    } else {
        NSAssert([meta matchID:ID], @"meta not match ID: %@, %@", ID, meta);
        cmd = [[DIMMetaCommand alloc] initWithID:ID meta:meta];
    }
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    return [messenger sendCommand:cmd];
}

@end
