// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  DIMAmanuensis.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMClerk()                [DIMAmanuensis sharedInstance]
#define DIMConversationWithID(ID) [DIMClerk() conversationWithID:(ID)]

@class DIMConversation;
@class DIMReceiptCommand;

@protocol DIMConversationDataSource;
@protocol DIMConversationDelegate;

/**
 *  Conversation pool to manage conversation instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMAmanuensis : NSObject

@property (weak, nonatomic) id<DIMConversationDataSource> conversationDataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> conversationDelegate;

+ (instancetype)sharedInstance;

/**
 *  Conversation factory
 *
 * @param ID - entity ID
 * @return conversation(chat box)
 */
- (DIMConversation *)conversationWithID:(DIMID *)ID;

- (void)addConversation:(DIMConversation *)chatBox;
- (void)removeConversation:(DIMConversation *)chatBox;

@end

@interface DIMAmanuensis (Message)

/**
 *  Save received message
 *
 * @param iMsg - instant message
 * @return YES on success
 */
- (BOOL)saveMessage:(DIMInstantMessage *)iMsg;

/**
 *  Update message state with receipt
 *
 * @param iMsg - receipt message
 * @return YES while target message found
 */
- (BOOL)saveReceipt:(DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
