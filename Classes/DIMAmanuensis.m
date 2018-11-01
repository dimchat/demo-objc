//
//  DIMAmanuensis.m
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMBarrack.h"

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

- (void)setDataSource:(id<DIMConversationDataSource>)dataSource {
    if (dataSource) {
        // update exists chatrooms
        DIMConversation *chatroom;
        for (id addr in _conversations) {
            chatroom = [_conversations objectForKey:addr];
            if (chatroom.dataSource == nil) {
                chatroom.dataSource = dataSource;
            }
        }
    }
    _dataSource = dataSource;
}

- (void)setDelegate:(id<DIMConversationDelegate>)delegate {
    if (delegate) {
        // update exists chatrooms
        DIMConversation *chatroom;
        for (id addr in _conversations) {
            chatroom = [_conversations objectForKey:addr];
            if (chatroom.delegate == nil) {
                chatroom.delegate = delegate;
            }
        }
    }
    _delegate = delegate;
}

- (DIMConversation *)conversationWithID:(const MKMID *)ID {
    DIMConversation *chatroom = [_conversations objectForKey:ID.address];
    if (!chatroom) {
        // get entity with ID
        MKMEntity *entity = nil;
        if (ID.address.network == MKMNetwork_Main) {
            entity = DIMContactWithID(ID);
        } else if (ID.address.network == MKMNetwork_Group) {
            entity = DIMGroupWithID(ID);
        }
        NSAssert(entity, @"ID error");
        // create new conversation with entity (Contact/Group)
        chatroom = [[DIMConversation alloc] initWithEntity:entity];
        [self setConversation:chatroom];
    }
    return chatroom;
}

- (void)setConversation:(DIMConversation *)chatroom {
    // check data source
    if (chatroom.dataSource == nil) {
        chatroom.dataSource = _dataSource;
    }
    // check delegate
    if (chatroom.delegate == nil) {
        chatroom.delegate = _delegate;
    }
    MKMID *ID = chatroom.ID;
    [_conversations setObject:chatroom forKey:ID.address];
}

- (void)removeConversation:(DIMConversation *)chatroom {
    MKMID *ID = chatroom.ID;
    [_conversations removeObjectForKey:ID.address];
}

@end
