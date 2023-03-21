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
//  DIMCommonMessenger.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/5.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMP/DIMMessageDBI.h>
#import <DIMP/DIMSession.h>
#import <DIMP/DIMCommonFacebook.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Common Messenger with Session & Database
 */
@interface DIMCommonMessenger : DIMMessenger <DIMTransmitter>

@property(nonatomic, readonly) __kindof DIMCommonFacebook *facebook;
@property(nonatomic, readonly) __kindof id<DIMSession> session;
@property(nonatomic, readonly) id<DIMMessageDBI> database;

@property(nonatomic, strong) id<DIMPacker> packer;
@property(nonatomic, strong) id<DIMProcessor> processor;

- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack
                         session:(id<DIMSession>)session
                        database:(id<DIMMessageDBI>)db
NS_DESIGNATED_INITIALIZER;

@end

// protected
@interface DIMCommonMessenger (Querying)

/**
 *  Request for meta with entity ID
 *
 * @param ID - entity ID
 * @return false on duplicated
 */
- (BOOL)queryMetaForID:(id<MKMID>)ID;

/**
 *  Request for meta & visa document with entity ID
 *
 * @param ID - entity ID
 * @return false on duplicated
 */
- (BOOL)queryDocumentForID:(id<MKMID>)ID;

/**
 *  Request for group members with group ID
 *
 * @param group - group ID
 * @return false on duplicated
 */
- (BOOL)queryMembersForID:(id<MKMID>)group;

@end

// protected
@interface DIMCommonMessenger (Waiting)

/**
 *  Add income message in a queue for waiting sender's visa
 *
 * @param rMsg - incoming message
 * @param info - error info
 */
- (void)suspendReliableMessage:(id<DKDReliableMessage>)rMsg
                     errorInfo:(NSDictionary<NSString *, id> *)info;

/**
 *  Add outgo message in a queue for waiting receiver's visa
 *
 * @param iMsg - outgo message
 * @param info - error info
 */
- (void)suspendInstantMessage:(id<DKDInstantMessage>)iMsg
                    errorInfo:(NSDictionary<NSString *, id> *)info;

@end

// protected
@interface DIMCommonMessenger (Checking)

// for checking whether user's ready
- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user;

// for checking whether group's ready
- (NSArray<id<MKMID>> *)membersForID:(id<MKMID>)group;

/**
 *  Check sender before verifying received message
 *
 * @param rMsg - network message
 * @return false on verify key not found
 */
- (BOOL)checkSenderForReliableMessage:(id<DKDReliableMessage>)rMsg;

- (BOOL)checkReceiverForSecureMessage:(id<DKDSecureMessage>)sMsg;

/**
 *  Check receiver before encrypting message
 *
 * @param iMsg - plain message
 * @return false on encrypt key not found
 */
- (BOOL)checkReceiverForInstantMessage:(id<DKDInstantMessage>)iMsg;

@end

NS_ASSUME_NONNULL_END
