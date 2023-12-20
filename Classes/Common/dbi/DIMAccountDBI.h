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

#import <ObjectKey/ObjectKey.h>
#import <DIMCore/DIMCore.h>

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
- (nullable id<MKMPrivateKey>)privateKeyForSignature:(id<MKMID>)user;

/**
 *  Get private key for user
 *
 * @param user - user ID
 * @return the private key matched with meta.key
 */
- (nullable id<MKMPrivateKey>)privateKeyForVisaSignature:(id<MKMID>)user;

@end

@protocol DIMMetaDBI <NSObject>

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)entity;

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)entity;

@end

@protocol DIMDocumentDBI <NSObject>

- (BOOL)saveDocument:(id<MKMDocument>)doc;

- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)entity;

@end

@protocol DIMUserDBI <NSObject>

- (NSArray<id<MKMID>> *)localUsers;

- (BOOL)saveLocalUsers:(NSArray<id<MKMID>> *)users;

@end

@protocol DIMContactDBI <NSObject>

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user;

- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)user;

@end

@protocol DIMGroupDBI <NSObject>

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)gid;

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)gid;
- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)gid;
- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid;
- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid;

@end

typedef OKPair<id<DKDGroupCommand>, id<DKDReliableMessage>> DIMHistoryCmdMsg;
typedef OKPair<id<DKDResetGroupCommand>, id<DKDReliableMessage>> DIMResetCmdMsg;

@protocol DIMGroupHistoryDBI <NSObject>

/**
 *  Save group commands
 *      1. invite
 *      2. expel (deprecated)
 *      3. join
 *      4. quit
 *      5. reset
 *      6. resign
 *
 * @param content - group command
 * @param rMsg    - group command message
 * @param gid     - group ID
 * @return false on failed
 */
- (BOOL)saveGroupHistory:(id<DKDGroupCommand>)content
             withMessage:(id<DKDReliableMessage>)rMsg
                   group:(id<MKMID>)gid;

/**
 *  Load group commands
 *      1. invite
 *      2. expel (deprecated)
 *      3. join
 *      4. quit
 *      5. reset
 *      6. resign
 *
 * @param group - group ID
 * @return history list
 */
- (NSArray<DIMHistoryCmdMsg *> *)historiesOfGroup:(id<MKMID>)group;

/**
 *  Load last 'reset' group command
 *
 * @param group - group ID
 * @return reset command message
 */
- (DIMResetCmdMsg *)resetCommandMessageForGroup:(id<MKMID>)group;

/**
 *  Clean group commands for members:
 *      1. invite
 *      2. expel (deprecated)
 *      3. join
 *      4. quit
 *      5. reset
 *
 * @param group - group ID
 * @return false on failed
 */
- (BOOL)clearMemberHistoriesOfGroup:(id<MKMID>)group;

/**
 *  Clean group commands for administrators
 *      1. resign
 *
 * @param group - group ID
 * @return false on failed
 */
- (BOOL)clearAdminHistoriesOfGroup:(id<MKMID>)group;

@end

/**
 *  Account DBI
 */
@protocol DIMAccountDBI <DIMPrivateKeyDBI,
                         DIMMetaDBI, DIMDocumentDBI,
                         DIMUserDBI, DIMContactDBI,
                         DIMGroupDBI, DIMGroupHistoryDBI>

@end

NS_ASSUME_NONNULL_END
