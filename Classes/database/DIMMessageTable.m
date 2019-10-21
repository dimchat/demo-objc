//
//  DIMMessageTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"
#import "LocalDatabaseManager.h"
#import "DIMMessageTable.h"

typedef NSMutableDictionary<DIMID *, NSArray *> CacheTableM;

@interface DIMMessageTable () {
    
    CacheTableM *_caches;
    NSMutableArray<DIMID *> *_conversations;
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

- (NSMutableArray<DIMID *> *)allConversations {
    
    if(_conversations == nil || _conversations.count == 0){
        _conversations = [[LocalDatabaseManager sharedInstance] loadAllConversations];
    }
    
    return _conversations;
}

- (void)_updateCache:(NSArray *)messages conversation:(DIMID *)ID {
    NSMutableArray *list = (NSMutableArray *)[self allConversations];
    
    if (messages) {
        // update cache
        [_caches setObject:messages forKey:ID];
        // add cid
        if (![list containsObject:ID]) {
            [list addObject:ID];
        }
    } else {
        // erase cache
        [_caches removeObjectForKey:ID];
        // remove cid
        [list removeObject:ID];
    }
}

- (nullable NSArray<DIMInstantMessage *> *)_loadMessages:(DIMID *)ID {
    return [[LocalDatabaseManager sharedInstance] loadMessagesInConversation:ID limit:-1 offset:-1];
}

- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMID *)ID {
    NSArray<DIMInstantMessage *> *messages = [_caches objectForKey:ID];
    if (!messages) {
        messages = [self _loadMessages:ID];
        [self _updateCache:messages conversation:ID];
    }
    return messages;
}

- (BOOL)addMessage:(DIMInstantMessage *)message toConversation:(DIMID *)ID{
    
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

- (BOOL)clearConversation:(DIMID *)ID{
    [self _updateCache:[NSArray array] conversation:ID];
    return [[LocalDatabaseManager sharedInstance] clearConversation:ID];
}

- (BOOL)removeConversation:(DIMID *)ID {
    return [[LocalDatabaseManager sharedInstance] deleteConversation:ID];
}

-(BOOL)markConversationMessageRead:(DIMID *)chatBox{
    return [[LocalDatabaseManager sharedInstance] markMessageRead:chatBox];
}

@end
