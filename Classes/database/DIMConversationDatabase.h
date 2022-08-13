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
//  DIMConversationDatabase.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMConversationDataSource <NSObject>

/**
 *  Get message count in this conversation for an entity
 *
 * @param chatBox - conversation ID
 * @return total count
 */
- (NSInteger)numberOfMessagesInConversation:(id<MKMID>)chatBox;

/**
 *  Get message at index of this conversation
 *
 * @param chatBox - conversation ID
 * @param index - start from 0, latest first
 * @return instant message
 */
- (id<DKDInstantMessage>)conversation:(id<MKMID>)chatBox messageAtIndex:(NSInteger)index;

@end

@protocol DIMConversationDelegate <NSObject>

/**
 *  Save the new message to local storage
 *
 * @param chatBox - conversation ID
 * @param iMsg - instant message
 */
- (BOOL)conversation:(id<MKMID>)chatBox insertMessage:(id<DKDInstantMessage>)iMsg;

@optional

/**
 *  Delete the message
 *
 * @param chatBox - conversation ID
 * @param iMsg - instant message
 */
- (BOOL)conversation:(id<MKMID>)chatBox removeMessage:(id<DKDInstantMessage>)iMsg;

/**
 *  Try to withdraw the message, maybe won't success
 *
 * @param chatBox - conversation ID
 * @param iMsg - instant message
 */
- (BOOL)conversation:(id<MKMID>)chatBox withdrawMessage:(id<DKDInstantMessage>)iMsg;

@end

@interface DIMConversationDatabase : NSObject <DIMConversationDataSource, DIMConversationDelegate>

- (NSArray<id<MKMID>> *)allConversations;
- (BOOL)removeConversation:(id<MKMID>)chatBox;
- (BOOL)clearConversation:(id<MKMID>)chatBox;
- (NSArray<id<DKDInstantMessage>> *)messagesInConversation:(id<MKMID>)chatBox;

-(BOOL)markConversationMessageRead:(id<MKMID>)chatBox;

@end

NS_ASSUME_NONNULL_END
