//
//  DIMAmanuensis.m
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMAmanuensis.h"

@interface DIMAmanuensis () {
    
    NSMutableDictionary<const MKMAddress *, DIMConversation *> *_conversations;
}

@end

@implementation DIMAmanuensis

static DIMAmanuensis *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

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
    //NSAssert(chatroom, @"chatroom not found");
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
