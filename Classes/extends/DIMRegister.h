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
//  DIMRegister.h
//  DIMP
//
//  Created by Albert Moky on 2019/12/20.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMRegister : NSObject

@property (readwrite, nonatomic) MKMEntityType type; // user type (0x00)

@property (strong, nonatomic, nullable) id<MKMPrivateKey> key; // user private key

/**
 *  Generate user account
 *
 * @param nickname - user name
 * @param url - avatar URL
 * @return User object
 */
- (id<DIMUser>)createUserWithName:(NSString *)nickname avatar:(nullable NSString *)url;

/**
 *  Generate group account (Polylogue)
 *
 * @param name - group name
 * @param ID - group founder
 * @return Group object
 */
- (id<DIMGroup>)createGroupWithName:(NSString *)name founder:(id<MKMID>)ID;
- (id<DIMGroup>)createGroupWithSeed:(NSString *)seed
                               name:(NSString *)name founder:(id<MKMID>)ID;

#pragma mark -

/**
 *  Step 1. generate private key (with asymmetric algorithm)
 *
 * @return private key (RSA)
 */
- (id<MKMPrivateKey>)generatePrivateKey;
- (id<MKMPrivateKey>)generatePrivateKeyWithAlgorithm:(NSString *)algorithm;

/**
 *  Step 2. generate meta with private key (and meta seed)
 *
 * @param name - "username" or "group-name"
 * @return meta
 */
- (id<MKMMeta>)generateUserMetaWithSeed:(nullable NSString *)name;
- (id<MKMMeta>)generateGroupMetaWithSeed:(NSString *)name;

/**
 *  Step 3. generate ID with meta (and network type)
 *
 * @param meta - user/group meta
 * @return user/group ID
 */
- (id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta;
- (id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta type:(MKMEntityType)network;

/**
 *  Step 4. create profile with ID and sign with private key
 *
 * @param ID - user/group ID
 * @param name - user/group name
 * @return user/group profile
 */
- (id<MKMDocument>)createGroupProfileWithID:(id<MKMID>)ID name:(NSString *)name;
- (id<MKMDocument>)createUserProfileWithID:(id<MKMID>)ID name:(NSString *)name avatar:(nullable NSString *)url;
- (id<MKMDocument>)credateProfileWithID:(id<MKMID>)ID properties:(NSDictionary *)info;

/**
 *  Step 5. upload meta & profile for ID
 *
 * @param ID - user/group ID
 * @param meta - user/group meta
 * @param profile - user/group profile
 * @return YES on success
 */
- (BOOL)uploadInfoWithID:(id<MKMID>)ID meta:(id<MKMMeta>)meta profile:(nullable id<MKMDocument>)profile;

@end

NS_ASSUME_NONNULL_END
