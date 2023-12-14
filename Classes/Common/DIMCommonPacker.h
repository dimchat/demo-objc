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
//  DIMCommonPacker.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/15.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommonPacker : DIMMessagePacker

@end

// protected
@interface DIMCommonPacker (Suspend)

/**
 *  Add income message in a queue for waiting sender's visa
 *
 * @param rMsg - incoming message
 * @param info - error info
 */
- (void)suspendReliableMessage:(id<DKDReliableMessage>)rMsg
                         error:(NSDictionary *)info;

/**
 *  Add outgo message in a queue for waiting receiver's visa
 *
 * @param iMsg - outgo message
 * @param info - error info
 */
- (void)suspendInstantMessage:(id<DKDInstantMessage>)iMsg
                        error:(NSDictionary *)info;

@end

// protected
@interface DIMCommonPacker (Checking)

- (nullable id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user;

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group;

/**
 *  Check sender before verifying received message
 *
 * @param rMsg - network message
 * @return false on verify key not found
 */
- (BOOL)checkSenderInReliableMessage:(id<DKDReliableMessage>)rMsg;

- (BOOL)checkReceiverInReliableMessage:(id<DKDReliableMessage>)sMsg;

/**
 *  Check receiver before encrypting message
 *
 * @param iMsg - plain message
 * @return false on encrypt key not found
 */
- (BOOL)checkReceiverInInstantMessage:(id<DKDInstantMessage>)iMsg;

@end

NS_ASSUME_NONNULL_END
