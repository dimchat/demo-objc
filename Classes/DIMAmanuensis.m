//
//  DIMAmanuensis.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMInstantMessage.h"

#import "DIMConversation.h"

#import "DIMAmanuensis.h"

@interface DIMAmanuensis () {
    
    NSMutableDictionary<const MKMAddress *, DIMConversation *> *_conversations;
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
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in _conversations) {
            chatBox = [_conversations objectForKey:addr];
            if (chatBox.dataSource == nil) {
                chatBox.dataSource = dataSource;
            }
        }
    }
    _conversationDataSource = dataSource;
}

- (void)setConversationDelegate:(id<DIMConversationDelegate>)delegate {
    if (delegate) {
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in _conversations) {
            chatBox = [_conversations objectForKey:addr];
            if (chatBox.delegate == nil) {
                chatBox.delegate = delegate;
            }
        }
    }
    _conversationDelegate = delegate;
}

- (DIMConversation *)conversationWithID:(const MKMID *)ID {
    DIMConversation *chatBox = [_conversations objectForKey:ID.address];
    if (!chatBox) {
        if (_conversationDelegate) {
            // create by delegate
            chatBox = [_conversationDelegate conversationWithID:ID];
        }
        if (!chatBox) {
            // create directly if we can find the entity
            // get entity with ID
            MKMEntity *entity = nil;
            if (MKMNetwork_IsPerson(ID.type)) {
                entity = MKMContactWithID(ID);
            } else if (MKMNetwork_IsGroup(ID.type)) {
                entity = MKMGroupWithID(ID);
            }
            NSAssert(entity, @"ID error");
            if (entity) {
                // create new conversation with entity(Account/Group)
                chatBox = [[DIMConversation alloc] initWithEntity:entity];
            }
        }
        NSAssert(chatBox, @"failed to create conversation: %@", ID);
        [self addConversation:chatBox];
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
    MKMID *ID = chatBox.ID;
    [_conversations setObject:chatBox forKey:ID.address];
}

- (void)removeConversation:(DIMConversation *)chatBox {
    MKMID *ID = chatBox.ID;
    [_conversations removeObjectForKey:ID.address];
}

@end

@implementation DIMAmanuensis (Message)

- (void)recvMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatBox = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    DIMMessageContent *content = iMsg.content;
    
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:receiver];
    } else if (content.group) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:content.group];
    } else {
        // personal chat, get chat box with contact ID
        chatBox = [self conversationWithID:sender];
    }
    
    [chatBox insertMessage:iMsg];
}

@end
