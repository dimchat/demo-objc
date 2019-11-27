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
//  DIMTerminal+Request.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNotificationName_MessageSent;
extern NSString * const kNotificationName_SendMessageFailed;

@interface DIMTerminal (Packing)

// pack and send message content to receiver
- (nullable DIMInstantMessage *)sendContent:(DIMContent *)content
                                         to:(DIMID *)receiver;

// pack and send command to station
- (void)sendCommand:(DIMCommand *)cmd;

// broadcast message content to everyone@everywhere
- (void)broadcastContent:(DIMContent *)content;

@end

@interface DIMTerminal (Request)

- (BOOL)login:(DIMUser *)user;

- (void)onHandshakeAccepted:(NSString *)session;

- (void)postProfile:(DIMProfile *)profile; // to station
- (void)broadcastProfile:(DIMProfile *)profile; // to all contacts

- (void)postContacts:(NSArray<DIMID *> *)contacts;

-(void)getContacts;
-(void)getMuteList;

- (void)queryMetaForID:(DIMID *)ID;
- (void)queryProfileForID:(DIMID *)ID;

- (void)queryOnlineUsers;
- (void)searchUsersWithKeywords:(NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
