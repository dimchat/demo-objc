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
//  DIMSession.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/5.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <StarTrek/StarTrek.h>

#import <DIMP/DIMSessionDBI.h>

NS_ASSUME_NONNULL_BEGIN

typedef OKPair<id<DKDInstantMessage>, id<DKDReliableMessage>> DIMTransmitterResults;

@protocol DIMTransmitter <NSObject>

/*
 *  Send content from sender to receiver with priority
 *
 * @param from     - sender ID, null for current user
 * @param to       - receiver ID
 * @param content  - message content
 * @param prior    - message priority, smaller is faster
 * @return (iMsg, None) on error
 */
- (DIMTransmitterResults *)sendContent:(id<DKDContent>)content
                                sender:(nullable id<MKMID>)from
                              receiver:(id<MKMID>)to
                              priority:(NSInteger)prior;

/**
 *  Send instant message with priority
 *
 * @param iMsg  - plain message
 * @param prior - smaller is faster
 * @return null on error
 */
- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior;

/**
 *  Send reliable message with priority
 *
 * @param rMsg  - encrypted & signed message
 * @param prior - smaller is faster
 * @return false on error
 */
- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg
                   priority:(NSInteger)prior;

@end

@protocol DIMSession <DIMTransmitter>

@property(nonatomic, readonly) id<DIMSessionDBI> database;

/**
 *  Get remote socket address
 *
 * @return host & port
 */
@property(nonatomic, readonly) id<NIOSocketAddress> remoteAddress;

// session key
- (NSString *)key;

/**
 *  Update user ID
 *
 * @param ID - login user ID
 * @return true on changed
 */
- (BOOL)setID:(nullable id<MKMID>)ID;
- (nullable id<MKMID>)ID;

/**
 *  Update active flag
 *
 * @param flag - active flag
 * @param when - now
 * @return true on changed
 */
- (BOOL)setActive:(BOOL)flag time:(NSTimeInterval)when;
- (BOOL)isActive;

/**
 *  Pack message into a waiting queue
 *
 * @param rMsg  - network message
 * @param data  - serialized message
 * @param prior - priority, smaller is faster
 * @return false on error
 */
- (BOOL)queueMessage:(id<DKDReliableMessage>)rMsg
             package:(NSData *)data
            priority:(NSInteger)prior;

@end

NS_ASSUME_NONNULL_END
