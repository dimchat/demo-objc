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
//  DIMAmanuensis.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "NSObject+Singleton.h"
#import "DIMFacebook+Extension.h"

#import "DIMConversation.h"

#import "DIMAmanuensis.h"

@interface DIMAmanuensis () {
    
    NSMutableDictionary<id<MKMAddress>, DIMConversation *> *_conversations;
}

@end

@implementation DIMAmanuensis

SingletonImplementations(DIMAmanuensis, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _conversations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setConversationDataSource:(id<DIMConversationDataSource>)dataSource {
    if (dataSource) {
        NSMutableDictionary<id<MKMAddress>, DIMConversation *> *list;
        list = [_conversations copy];
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in list) {
            chatBox = [list objectForKey:addr];
            if (chatBox.dataSource == nil) {
                chatBox.dataSource = dataSource;
            }
        }
    }
    _conversationDataSource = dataSource;
}

- (void)setConversationDelegate:(id<DIMConversationDelegate>)delegate {
    if (delegate) {
        NSMutableDictionary<id<MKMAddress>, DIMConversation *> *list;
        list = [_conversations copy];
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in list) {
            chatBox = [list objectForKey:addr];
            if (chatBox.delegate == nil) {
                chatBox.delegate = delegate;
            }
        }
    }
    _conversationDelegate = delegate;
}

- (DIMConversation *)conversationWithID:(id<MKMID>)ID {
    DIMConversation *chatBox = [_conversations objectForKey:ID.address];
    if (!chatBox) {
        // create directly if we can find the entity
        // get entity with ID
        DIMEntity *entity = nil;
        if (MKMIDIsUser(ID)) {
            entity = DIMUserWithID(ID);
        } else if (MKMIDIsGroup(ID)) {
            entity = DIMGroupWithID(ID);
        }
        //NSAssert(entity, @"ID error: %@", ID);
        if(entity != nil){
            if (entity) {
                // create new conversation with entity(User/Group)
                chatBox = [[DIMConversation alloc] initWithEntity:entity];
            }
            NSAssert(chatBox, @"failed to create conversation: %@", ID);
            [self addConversation:chatBox];
        }
    }
    return chatBox;
}

- (void)addConversation:(DIMConversation *)chatBox {
    // check data source
    if (chatBox.dataSource == nil) {
        chatBox.dataSource = _conversationDataSource;
    }
    // check delegate
    if (chatBox.delegate == nil) {
        chatBox.delegate = _conversationDelegate;
    }
    id<MKMID> ID = chatBox.ID;
    [_conversations setObject:chatBox forKey:ID.address];
}

- (void)removeConversation:(DIMConversation *)chatBox {
    id<MKMID> ID = chatBox.ID;
    [_conversations removeObjectForKey:ID.address];
}

@end

@implementation DIMAmanuensis (Message)

- (BOOL)saveMessage:(id<DKDInstantMessage>)iMsg {
    id<DKDContent> content = iMsg.content;
    if ([content isKindOfClass:[DIMReceiptCommand class]]) {
        // it's a receipt
        NSLog(@"update target msg.state with receipt: %@", content);
        return [self saveReceipt:iMsg];
    }
    
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatBox = nil;
    
    id<DKDEnvelope> env = iMsg.envelope;
    id<MKMID> sender = env.sender;
    id<MKMID> receiver = env.receiver;
    id<MKMID> groupID = iMsg.content.group;
    
    if (MKMIDIsGroup(receiver)) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:receiver];
    } else if (groupID) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:groupID];
    } else {
        // personal chat, get chat box with contact ID
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        DIMUser *user = [facebook currentUser];
        if ([sender isEqual:user.ID]) {
            chatBox = [self conversationWithID:receiver];
        } else {
            chatBox = [self conversationWithID:sender];
        }
    }
    
    //NSAssert(chatBox, @"chat box not found for message: %@", iMsg);
    return [chatBox insertMessage:iMsg];
}

- (BOOL)saveReceipt:(id<DKDInstantMessage>)iMsg {
    id<DKDContent> content = iMsg.content;
    if (![content isKindOfClass:[DIMReceiptCommand class]]) {
        NSAssert(false, @"this is not a receipt: %@", iMsg);
        return NO;
    }
    DIMReceiptCommand *receipt = (DIMReceiptCommand *)content;
    NSLog(@"saving receipt: %@", iMsg);

    DIMConversation *chatBox = nil;
    
    // NOTE: this is the receipt's commander,
    //       it can be a station, or the original message's receiver
    id<MKMID> sender = iMsg.envelope.sender;
    
    // NOTE: this is the original message's receiver
    id<MKMID> receiver = receipt.envelope.receiver;
    
    // FIXME: only the real receiver will know the exact message detail, so
    //        the station may not know if this is a group message.
    //        maybe we should try another way to search the exact conversation.
    id<MKMID> groupID = receipt.group;
    
    if (receiver == nil) {
        NSLog(@"receiver not found, it's not a receipt for instant message");
        return NO;
    }
    
    if (groupID) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:groupID];
    } else {
        // personal chat, get chat box with contact ID
        chatBox = [self conversationWithID:receiver];
    }
    
    NSAssert(chatBox, @"chat box not found for receipt: %@", receipt);
    id<DKDInstantMessage> targetMessage;
    targetMessage = [self _conversation:chatBox messageMatchReceipt:receipt];
    if (targetMessage) {
        DKDContent *targetContent = targetMessage.content;
        if ([sender isEqual:receiver]) {
            // the receiver's client feedback
            if ([receipt.message containsString:@"read"]) {
                targetContent.state = DIMMessageState_Read;
            } else {
                targetContent.state = DIMMessageState_Arrived;
            }
        } else if (MKMNetwork_IsStation(sender.type)) {
            // delivering or delivered to receiver (station said)
            if ([receipt.message containsString:@"delivered"]) {
                targetContent.state = DIMMessageState_Delivered;
            } else {
                targetContent.state = DIMMessageState_Delivering;
            }
        } else {
            NSAssert(false, @"unexpect receipt sender: %@", sender);
            return NO;
        }
        return YES;
    }
    
    NSLog(@"target message not found for receipt: %@", receipt);
    return NO;
}

- (nullable id<DKDInstantMessage>)_conversation:(DIMConversation *)chatBox
                          messageMatchReceipt:(DIMReceiptCommand *)receipt {
    id<DKDInstantMessage> iMsg = nil;
    NSInteger count = [chatBox numberOfMessage];
    for (NSInteger index = count - 1; index >= 0; --index) {
        iMsg = [chatBox messageAtIndex:index];
        if ([(DKDInstantMessage *)iMsg matchReceipt:receipt]) {
            return iMsg;
        }
    }
    return nil;
}

@end
