// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMPrivateKeyStore.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/20.
//

#import <DIMPlugins/MKMPrivateKey+Store.h>

#import "DIMPrivateKeyStore.h"

static inline NSString *private_label(NSString *type, id<MKMID> ID) {
    NSString *address = [ID.address string];
    if ([type length] == 0) {
        return address;
    }
    return [NSString stringWithFormat:@"%@:%@", type, address];
}

static inline BOOL private_save(id<MKMPrivateKey> key, NSString *type, id<MKMID> ID) {
    NSString *label = private_label(type, ID);
    return MKMPrivateKeySave(label, key);
}

static inline id<MKMPrivateKey> private_load(NSString *type, id<MKMID> ID) {
    NSString *label = private_label(type, ID);
    return MKMPrivateKeyLoad(label);
}

@implementation DIMPrivateKeyStore

OKSingletonImplementations(DIMPrivateKeyStore, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}

// Override
- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key
              withType:(NSString *)type
               forUser:(id<MKMID>)user {
    // TODO: support multi private keys
    BOOL ok = private_save(key, type, user);
    NSLog(@"save private key: %d, %@", ok, user);
    return ok;
}

// Override
- (id<MKMPrivateKey>)privateKeyForSignature:(id<MKMID>)user {
    // TODO: support multi private keys
    return [self privateKeyForVisaSignature:user];
}

// Override
- (id<MKMPrivateKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    id<MKMPrivateKey> key;
    // get private key paired with meta.key
    key = private_load(DIMPrivateKeyType_Meta, user);
    if (!key) {
        // get private key paired with meta.key
        key = private_load(nil, user);
    }
    NSLog(@"load private key: %@, %@", [key algorithm], user);
    return key;
}

// Override
- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    id<MKMPrivateKey> key;
    // 1. get private key paired with visa.key
    key = private_load(DIMPrivateKeyType_Visa, user);
    if (key) {
        [mArray addObject:key];
    }
    // get private key paired with meta.key
    key = private_load(DIMPrivateKeyType_Meta, user);
    if ([key conformsToProtocol:@protocol(MKMDecryptKey)]) {
        [mArray addObject:key];
    }
    // get private key paired with meta.key
    key = private_load(nil, user);
    if ([key conformsToProtocol:@protocol(MKMDecryptKey)]) {
        [mArray addObject:key];
    }
    NSLog(@"load private keys: %lu, %@", [mArray count], user);
    return mArray;
}

@end
