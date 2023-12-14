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
//  DIMGroupCommandProcessor.h
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>

#import <DIMClient/DIMHistoryProcessor.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupCommandProcessor : DIMHistoryCommandProcessor

/**
 *  send a command list with newest members to the receiver
 */
- (BOOL)sendHistoriesTo:(id<MKMID>)receiver group:(id<MKMID>)gid;

// protected
- (BOOL)saveHistory:(id<DKDGroupCommand>)content
        withMessage:(id<DKDReliableMessage>)rMsg
              group:(id<MKMID>)gid;

@end

// protected
@interface DIMGroupCommandProcessor (Membership)

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid;

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid;

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)gid;

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

@end

typedef NSArray<id<MKMID>> DIMIDList;
typedef NSArray<id<DKDContent>> DIMContentList;

typedef OKPair<id<MKMID>, DIMContentList *> DIMCommandExpiredResults;
typedef OKPair<DIMIDList *, DIMContentList *> DIMCommandMembersResults;
typedef OKTriplet<id<MKMID>, DIMIDList *, DIMContentList *> DIMGroupMembersResults;

// protected
@interface DIMGroupCommandProcessor (Checking)

- (DIMCommandExpiredResults *)checkCommandExpired:(id<DKDGroupCommand>)content
                                          message:(id<DKDReliableMessage>)rMsg;

- (DIMCommandMembersResults *)checkCommandMembers:(id<DKDGroupCommand>)content
                                          message:(id<DKDReliableMessage>)rMsg;

- (DIMGroupMembersResults *)checkGroupMembers:(id<DKDGroupCommand>)content
                                      message:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
