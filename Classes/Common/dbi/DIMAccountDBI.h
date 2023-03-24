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
//  DIMAccountDBI.h
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

//
//  Conveniences
//

NSArray<id<MKMDecryptKey>> *DIMConvertDecryptKeys(NSArray<id<MKMPrivateKey>> *privateKeys);
NSArray<id<MKMPrivateKey>> *DIMConvertPrivateKeys(NSArray<id<MKMDecryptKey>> *decryptKeys);

NSArray<NSDictionary<NSString *, id> *> *DIMRevertPrivateKeys(NSArray<id<MKMPrivateKey>> *privateKeys);

NSArray<id<MKMPrivateKey>> *DIMUnshiftPrivateKey(id<MKMPrivateKey> key, NSMutableArray<id<MKMPrivateKey>> *privateKeys);
NSInteger DIMFindPrivateKey(id<MKMPrivateKey> key, NSArray<id<MKMPrivateKey>> *privateKeys);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define DIMPrivateKeyType_Meta @"M"
#define DIMPrivateKeyType_Visa @"V"

@protocol DIMPrivateKeyDBI <NSObject>

/**
 *  Save private key for user
 *
 * @param user - user ID
 * @param key - private key
 * @param type - 'M' for matching meta.key; or 'P' for matching profile.key
 * @return false on error
 */
- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key withType:(NSString *)type forUser:(id<MKMID>)user;

/**
 *  Get private keys for user
 *
 * @param user - user ID
 * @return all keys marked for decryption
 */
- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user;

/**
 *  Get private key for user
 *
 * @param user - user ID
 * @return first key marked for signature
 */
- (id<MKMPrivateKey>)privateKeyForSignature:(id<MKMID>)user;

/**
 *  Get private key for user
 *
 * @param user - user ID
 * @return the private key matched with meta.key
 */
- (id<MKMPrivateKey>)privateKeyForVisaSignature:(id<MKMID>)user;

@end

@protocol DIMMetaDBI <NSObject>

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)entity;

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)entity;

@end

@protocol DIMDocumentDBI <NSObject>

- (BOOL)saveDocument:(id<MKMDocument>)doc;

- (nullable id<MKMDocument>)documentForID:(id<MKMID>)entity type:(nullable NSString *)type;

@end

@protocol DIMUserDBI <NSObject>

- (NSArray<id<MKMID>> *)localUsers;

- (BOOL)saveLocalUsers:(NSArray<id<MKMID>> *)users;

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user;

- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)user;

@end

@protocol DIMGroupDBI <NSObject>

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group;

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group;

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group;
- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group;
- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)gid;

@end

/**
 *  Account DBI
 */
@protocol DIMAccountDBI <DIMPrivateKeyDBI, DIMMetaDBI, DIMDocumentDBI, DIMUserDBI, DIMGroupDBI>

@end

NS_ASSUME_NONNULL_END
