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
//  DIMMessageTable.m
//  DIMP
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "LocalDatabaseManager.h"
#import "DIMMessageTable.h"

typedef NSMutableDictionary<id<MKMID>, NSArray *> CacheTableM;

@interface DIMMessageTable () {
    
    CacheTableM *_caches;
    NSMutableArray<id<MKMID>> *_conversations;
}

@end

@implementation DIMMessageTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
        _conversations = nil;
    }
    return self;
}

- (NSMutableArray<id<MKMID>> *)allConversations {
    
    if(_conversations == nil || _conversations.count == 0){
        _conversations = [[LocalDatabaseManager sharedInstance] loadAllConversations];
    }
    
    return _conversations;
}

- (void)_updateCache:(NSArray *)messages conversation:(id<MKMID>)ID {
    NSMutableArray *list = (NSMutableArray *)[self allConversations];
    
    if (messages) {
        // update cache
        [_caches setObject:messages forKey:ID];
        // add cid
        if (![list containsObject:ID]) {
            
            if(messages.count > 0){
                [list addObject:ID];
            }
        }
    } else {
        // erase cache
        [_caches removeObjectForKey:ID];
        // remove cid
        [list removeObject:ID];
    }
}

- (nullable NSArray<id<DKDInstantMessage>> *)_loadMessages:(id<MKMID>)ID {
    return [[LocalDatabaseManager sharedInstance] loadMessagesInConversation:ID limit:-1 offset:-1];
}

- (NSArray<id<DKDInstantMessage>> *)messagesInConversation:(id<MKMID>)ID {
    NSArray<id<DKDInstantMessage>> *messages = [_caches objectForKey:ID];
    if (!messages) {
        messages = [self _loadMessages:ID];
        [self _updateCache:messages conversation:ID];
    }
    return messages;
}

- (BOOL)addMessage:(id<DKDInstantMessage>)message toConversation:(id<MKMID>)ID{
    
    BOOL insertSuccess = [[LocalDatabaseManager sharedInstance] addMessage:message toConversation:ID];
    
    if(insertSuccess){
        //Update cache
        NSMutableArray *currentMessages = [[NSMutableArray alloc] initWithArray:[_caches objectForKey:ID]];
        [currentMessages addObject:message];
        [self _updateCache:currentMessages conversation:ID];
        
        if(![_conversations containsObject:ID]){
            [_conversations addObject:ID];
        }
    }
    
    return insertSuccess;
}

- (BOOL)clearConversation:(id<MKMID>)ID{
    [self _updateCache:[NSArray array] conversation:ID];
    return [[LocalDatabaseManager sharedInstance] clearConversation:ID];
}

- (BOOL)removeConversation:(id<MKMID>)ID {
    return [[LocalDatabaseManager sharedInstance] deleteConversation:ID];
}

-(BOOL)markConversationMessageRead:(id<MKMID>)chatBox{
    return [[LocalDatabaseManager sharedInstance] markMessageRead:chatBox];
}

@end
