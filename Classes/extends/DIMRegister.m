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

- (DIMUser *)createUserWithName:(NSString *)nickname avatar:(nullable NSString *)url {
    // 1. generate private key
    _key = [self generatePrivateKey];
    // 2. generate meta
    id<MKMMeta> meta = [self generateUserMetaWithSeed:@"user"];
    // 3. generate ID
    id<MKMID> ID = [self generateIDWithMeta:meta];
    // 4. generate profile
    id<MKMDocument> profile = [self createProfileWithID:ID name:nickname avatar:url];
    // 5. save private key, meta & profile in local storage
    //    don't forget to upload them onto the DIM station
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    [facebook savePrivateKey:_key type:DIMPrivateKeyType_Meta user:ID];
    [facebook saveMeta:meta forID:ID];
    [facebook saveDocument:profile];
    // 6. create user
    return [facebook userWithID:ID];
}

- (DIMGroup *)createGroupWithName:(NSString *)name founder:(id<MKMID>)founder {
    uint32_t seed = arc4random();
    NSString *string = [NSString stringWithFormat:@"Group-%u", seed];
    return [self createGroupWithSeed:string name:name founder:founder];
}

- (DIMGroup *)createGroupWithSeed:(NSString *)seed
                             name:(NSString *)name
                          founder:(id<MKMID>)founder {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    // 1. get private key
    _key = (id<MKMPrivateKey>)[facebook privateKeyForSignature:founder];
    // 2. generate meta
    id<MKMMeta> meta = [self generateGroupMetaWithSeed:seed];
    // 3. generate ID
    id<MKMID> group = [self generateIDWithMeta:meta network:MKMNetwork_Polylogue];
    // 4. generate profile
    id<MKMDocument> profile = [self createProfileWithID:group name:name];
    // 5. save meta & profile in local storage
    //    don't forget to upload them onto the DIM station
    [facebook saveMeta:meta forID:group];
    [facebook saveDocument:profile];
    // 6. add founder as first member
    [facebook group:group addMember:founder];
    // 7. create group
    return [facebook groupWithID:group];
}

- (__kindof id<MKMPrivateKey>)generatePrivateKey {
    return [self generatePrivateKeyWithAlgorithm:MKMAlgorithmECC];
}

- (__kindof id<MKMPrivateKey>)generatePrivateKeyWithAlgorithm:(NSString *)algorithm {
    return MKMPrivateKeyWithAlgorithm(algorithm);
}

- (__kindof id<MKMMeta>)generateUserMetaWithSeed:(nullable NSString *)name {
    // meta type "ETH" has no seed
    name = nil;
    return [self generateMetaWithType:MKMMetaVersion_ETH seed:name];
}

- (__kindof id<MKMMeta>)generateGroupMetaWithSeed:(NSString *)name {
    return [self generateMetaWithType:MKMMetaDefaultVersion seed:name];
}

- (__kindof id<MKMMeta>)generateMetaWithType:(UInt8)type seed:(nullable NSString *)name {
    NSAssert(_key, @"private key not set yet");
    return MKMMetaGenerate(type, _key, name);
}

- (id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta {
    return [self generateIDWithMeta:meta network:_network];
}

- (id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta network:(UInt8)type {
    return [meta generateID:type terminal:nil];
}

- (__kindof id<MKMDocument>)createProfileWithID:(id<MKMID>)ID name:(NSString *)name {
    return [self createProfileWithID:ID name:name avatar:nil];
}

- (__kindof id<MKMDocument>)createProfileWithID:(id<MKMID>)ID name:(NSString *)name avatar:(nullable NSString *)url {
    NSAssert(_key, @"private key not set yet");
    id<MKMVisa> doc = MKMDocumentNew(ID, MKMIDIsUser(ID) ? MKMDocument_Visa : MKMDocument_Bulletin);
    [doc setName:name];
    if (url) {
        [doc setAvatar:url];
    }
    if (![_key conformsToProtocol:@protocol(MKMDecryptKey)]) {
        MKMPrivateKey *sKey = [self generatePrivateKeyWithAlgorithm:MKMAlgorithmRSA];
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        [facebook savePrivateKey:sKey type:DIMPrivateKeyType_Visa user:ID];
        [doc setKey:sKey.publicKey];
    }
    [doc sign:_key];
    return doc;
}

- (__kindof id<MKMDocument>)credateProfileWithID:(id<MKMID>)ID properties:(NSDictionary *)info {
    NSAssert(_key, @"private key not set yet");
    id<MKMDocument> doc = MKMDocumentNew(ID, MKMIDIsUser(ID) ? MKMDocument_Visa : MKMDocument_Bulletin);
    for (NSString *name in info) {
        [doc setProperty:[info objectForKey:name] forKey:name];
    }
    [doc sign:_key];
    return doc;
}

- (BOOL)uploadInfoWithID:(id<MKMID>)ID meta:(id<MKMMeta>)meta profile:(nullable id<MKMDocument>)doc {
    DIMCommand *cmd;
    if (doc) {
        NSAssert([ID isEqual:doc.ID], @"document ID not match: %@, %@", ID, doc);
        NSAssert([doc isValid], @"document not valid: %@", doc);
        cmd = [[DIMDocumentCommand alloc] initWithID:ID meta:meta document:doc];
    } else {
        NSAssert([meta matchID:ID], @"meta not match ID: %@, %@", ID, meta);
        cmd = [[DIMMetaCommand alloc] initWithID:ID meta:meta];
    }
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    return [messenger sendCommand:cmd];
}

@end
