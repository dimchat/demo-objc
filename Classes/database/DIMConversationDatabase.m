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
//  DIMP
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"

#import "DIMMessageTable.h"
#import "DIMPConstants.h"

#import "DIMConversationDatabase.h"

@interface DIMConversationDatabase () {
    
    DIMMessageTable *_messageTable;
}

@end

@implementation DIMConversationDatabase

- (instancetype)init {
    if (self = [super init]) {
        _messageTable = [[DIMMessageTable alloc] init];
    }
    return self;
}

- (NSArray<id<MKMID>> *)allConversations {
    return [_messageTable allConversations];
}

- (BOOL)removeConversation:(id<MKMID>)chatBox {
    BOOL result = [_messageTable removeConversation:chatBox];
    
    if(result){
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kNotificationName_MessageCleaned object:self
                        userInfo:@{@"ID": chatBox}];
    }
    
    return result;
}

- (BOOL)clearConversation:(id<MKMID>)chatBox {
    return [_messageTable clearConversation:chatBox];
}

- (NSArray<id<DKDInstantMessage>> *)messagesInConversation:(id<MKMID>)chatBox {
    return [_messageTable messagesInConversation:chatBox];
}

-(BOOL)markConversationMessageRead:(id<MKMID>)chatBox{
    BOOL result = [_messageTable markConversationMessageRead:chatBox];
    
    if(result){
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:DIMConversationUpdatedNotification object:self
                        userInfo:@{@"ID": chatBox}];
    }
    
    return result;
}

#pragma mark DIMConversationDataSource

- (NSInteger)numberOfMessagesInConversation:(id<MKMID>)chatBox {
    NSArray<id<DKDInstantMessage>> *messages;
    messages = [_messageTable messagesInConversation:chatBox];
    return messages.count;
}

- (id<DKDInstantMessage>)conversation:(id<MKMID>)chatBox messageAtIndex:(NSInteger)index {
    NSArray<id<DKDInstantMessage>> *messages;
    messages = [_messageTable messagesInConversation:chatBox];
    NSAssert(index < messages.count, @"out of data: %ld, %lu", index, messages.count);
    return [messages objectAtIndex:index];
}

#pragma mark DIMConversationDelegate

- (BOOL)conversation:(id<MKMID>)chatBox insertMessage:(id<DKDInstantMessage>)iMsg {
    
    BOOL OK = [_messageTable addMessage:iMsg toConversation:chatBox];
    
    if (OK) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc postNotificationName:DIMConversationUpdatedNotification object:self
                        userInfo:@{@"ID": chatBox}];
        
        [nc postNotificationName:DIMMessageInsertedNotifiation object:self
                        userInfo:@{@"Conversation": chatBox, @"Message": iMsg}];
    }
    
    return OK;
    
//    NSArray<id<DKDInstantMessage>> *messages;
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
