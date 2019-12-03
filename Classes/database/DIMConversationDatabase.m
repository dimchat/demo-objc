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
//  DIMConversationDatabase.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"

#import "DIMMessageTable.h"
#import "DIMClientConstants.h"

#import "DIMConversationDatabase.h"

typedef NSMutableDictionary<DIMID *, DIMConversation *> ConversationTableM;

@interface DIMConversationDatabase () {
    
    DIMMessageTable *_messageTable;
    ConversationTableM *_conversationTable;
}

@end

@implementation DIMConversationDatabase

- (instancetype)init {
    if (self = [super init]) {
        _messageTable = [[DIMMessageTable alloc] init];
        _conversationTable = nil;
    }
    return self;
}

- (NSArray<DIMConversation *> *)allConversations {
    if (!_conversationTable) {
        NSArray<DIMID *> *array = [_messageTable allConversations];
        _conversationTable = [[ConversationTableM alloc] init];
        DIMConversation *chatBox;
        for (DIMID *ID in array) {
            chatBox = [self conversationWithID:ID];
            NSAssert(chatBox, @"conversation ID error: %@", ID);
            [_conversationTable setObject:chatBox forKey:ID];
        }
    }
    return [_conversationTable allValues];
}

- (BOOL)removeConversation:(DIMConversation *)chatBox {
    [_conversationTable removeObjectForKey:chatBox.ID];
    BOOL result = [_messageTable removeConversation:chatBox.ID];
    
    if(result){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageCleaned object:nil userInfo:@{@"ID": chatBox.ID}];
    }
    
    return result;
}

- (BOOL)clearConversation:(DIMConversation *)chatBox {
    return [_messageTable clearConversation:chatBox.ID];
}

- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMConversation *)chatBox {
    return [_messageTable messagesInConversation:chatBox.ID];
}

-(BOOL)markConversationMessageRead:(DIMConversation *)chatBox{
    BOOL result = [_messageTable markConversationMessageRead:chatBox.ID];
    
    if(result){
        [[NSNotificationCenter defaultCenter] postNotificationName:DIMConversationUpdatedNotification object:nil userInfo:@{@"ID": chatBox.ID}];
    }
    
    return result;
}

#pragma mark DIMConversationDataSource

- (NSInteger)numberOfMessagesInConversation:(DIMConversation *)chatBox {
    NSArray<DIMInstantMessage *> *messages;
    messages = [_messageTable messagesInConversation:chatBox.ID];
    return messages.count;
}

- (DIMInstantMessage *)conversation:(DIMConversation *)chatBox messageAtIndex:(NSInteger)index {
    NSArray<DIMInstantMessage *> *messages;
    messages = [_messageTable messagesInConversation:chatBox.ID];
    NSAssert(index < messages.count, @"out of data: %ld, %lu", index, messages.count);
    return [messages objectAtIndex:index];
}

#pragma mark DIMConversationDelegate

- (DIMConversation *)conversationWithID:(DIMID *)ID {
    DIMConversation *chatBox = [_conversationTable objectForKey:ID];
    if (chatBox) {
        return chatBox;
    }
    // create entity
    DIMEntity *entity = nil;
    if (MKMNetwork_IsUser(ID.type)) {
        entity = DIMUserWithID(ID);
    } else if (MKMNetwork_IsGroup(ID.type)) {
        entity = DIMGroupWithID(ID);
    }
    if (entity) {
        // create new conversation with entity (User/Group)
        chatBox = [[DIMConversation alloc] initWithEntity:entity];
        chatBox.dataSource = self;
        chatBox.delegate = self;
        
        if(chatBox.numberOfMessage > 0){
            // cache it
            [_conversationTable setObject:chatBox forKey:ID];
        }
        return chatBox;
    }
    NSAssert(false, @"failed to create conversation with ID: %@", ID);
    return nil;
}

- (BOOL)conversation:(DIMConversation *)chatBox insertMessage:(DIMInstantMessage *)iMsg {
    
    BOOL OK = [_messageTable addMessage:iMsg toConversation:chatBox.ID];
    
    if (OK) {
        [_conversationTable setObject:chatBox forKey:chatBox.ID];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DIMConversationUpdatedNotification object:nil userInfo:@{@"ID": chatBox.ID}];
        NSDictionary *userInfo = @{@"Conversation": chatBox.ID, @"Message": iMsg};
        [[NSNotificationCenter defaultCenter] postNotificationName:DIMMessageInsertedNotifiation object:nil userInfo:userInfo];
    }
    
    return OK;
    
//    NSArray<DIMInstantMessage *> *messages;
//    messages = [_messageTable messagesInConversation:chatBox.ID];
//    if (!messages) {
//        messages = [[NSMutableArray alloc] initWithCapacity:1];
//    }
//    [(NSMutableArray *)messages addObject:iMsg];
//
//    // TODO: Burn After Reading
//    return [_messageTable saveMessages:messages conversation:chatBox.ID];
}

@end
