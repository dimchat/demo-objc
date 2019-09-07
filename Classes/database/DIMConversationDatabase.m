//
//  DIMConversationDatabase.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"
#import "DIMMessageTable.h"

#import "DIMConversationDatabase.h"

typedef NSMutableDictionary<DIMID *, DIMConversation *> ConversationTableM;

@interface DIMConversationDatabase () {
    
    DIMMessageTable *_messageTable;
    
    // memory cache
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
    return [_messageTable removeConversation:chatBox.ID];
}

- (BOOL)clearConversation:(DIMConversation *)chatBox {
    NSArray<DIMInstantMessage *> *list = [[NSMutableArray alloc] init];
    return [_messageTable saveMessages:list conversation:chatBox.ID];
}

- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMConversation *)chatBox {
    return [_messageTable messagesInConversation:chatBox.ID];
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
    NSAssert(index < messages.count, @"out of data");
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
        // cache it
        [_conversationTable setObject:chatBox forKey:ID];
        return chatBox;
    }
    NSAssert(false, @"failed to create conversation with ID: %@", ID);
    return nil;
}

- (BOOL)conversation:(DIMConversation *)chatBox insertMessage:(DIMInstantMessage *)iMsg {
    
    // preprocess
    DIMContent *content = iMsg.content;
    if (content.type == DKDContentType_Command) {
        // system command
        DIMCommand *cmd = (DIMCommand *)content;
        NSLog(@"command: %@", cmd.command);
        
        // TODO: parse & execute system command
        // ...
    } else if (content.type == DKDContentType_History) {
        DIMID *groupID = DIMIDWithString(content.group);
        if (groupID) {
            // group command
            DIMGroupCommand *cmd = (DIMGroupCommand *)content;
            DIMID *sender = DIMIDWithString(iMsg.envelope.sender);
            if (![self processGroupCommand:cmd commander:sender]) {
                NSLog(@"group comment error: %@", content);
                return NO;
            }
        }
    }

    NSArray<DIMInstantMessage *> *messages;
    messages = [_messageTable messagesInConversation:chatBox.ID];
    if (!messages) {
        messages = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [(NSMutableArray *)messages addObject:iMsg];
    
    // TODO: Burn After Reading
    
    return [_messageTable saveMessages:messages conversation:chatBox.ID];
}

@end
