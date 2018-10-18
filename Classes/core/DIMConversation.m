//
//  DIMConversation.m
//  DIM
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMContact.h"
#import "DIMGroup.h"

#import "DIMEnvelope.h"
#import "DIMInstantMessage.h"

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) MKMEntity *entity; // Contact or Group

@end

@implementation DIMConversation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMEntity *entity = nil;
    self = [self initWithEntity:entity];
    return self;
}

- (instancetype)initWithEntity:(const MKMEntity *)entity {
    if (self = [super init]) {
        _entity = [entity copy];
        
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (DIMConversationType)type {
    return _entity.ID.address.network;
}

- (MKMID *)ID {
    return _entity.ID;
}

- (NSString *)title {
    if (self.type == DIMConversationPersonal) {
        NSAssert([_entity isKindOfClass:[DIMContact class]], @"error");
        DIMContact *contact = (DIMContact *)_entity;
        NSString *name = contact.name;
        // "xxx"
        return name;
    } else if (self.type == DIMConversationGroup) {
        NSAssert([_entity isKindOfClass:[DIMGroup class]], @"error");
        DIMGroup *group = (DIMGroup *)_entity;
        NSString *name = group.name;
        NSUInteger count = group.members.count;
        // "yyy (123)"
        return [[NSString alloc] initWithFormat:@"%@ (%lu)", name, count];
    }
    return @"Conversation";
}

- (NSInteger)insertInstantMessage:(const DIMInstantMessage *)iMsg {
    NSUInteger pos = 0;
    NSDate *time = iMsg.envelope.time;
    DIMInstantMessage *item;
    for (item in _messages) {
        if ([item.envelope.time compare:time] == NSOrderedDescending) {
            // item.envelope.time > iMsg.envelope.time
            break;
        }
        ++pos;
    }
    [_messages insertObject:iMsg atIndex:pos];
    
    [_delegate conversation:self didReceiveMessage:iMsg];
    return pos;
}

- (NSArray *)messagesWithRange:(NSRange)range {
    NSUInteger expect = range.location + range.length;
    if (_messages.count < expect) {
        // get time of last message
        const DIMInstantMessage *iMsg = _messages.lastObject;
        iMsg = [DIMInstantMessage messageWithMessage:iMsg];
        NSDate *time = iMsg ? iMsg.envelope.time : [NSDate date];
        
        // get messages before that time
        NSArray *array = [_delegate conversation:self
                                  messagesBefore:time
                                        maxCount:(expect - _messages.count)];
        for (id item in array) {
            iMsg = [DIMInstantMessage messageWithMessage:item];
            [_messages addObject:iMsg];
        }
    }
    
    if (_messages.count <= range.location) {
        return nil;
    }
    if (_messages.count < expect) {
        range = NSMakeRange(range.location, _messages.count - range.location);
    }
    
    return [_messages subarrayWithRange:range];
}

@end

#pragma mark - Conversations Pool

@interface DIMConversationManager () {
    
    NSMutableDictionary<const MKMAddress *, DIMConversation *> *_conversations;
}

@end

@implementation DIMConversationManager

static DIMConversationManager *s_sharedInstance = nil;

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

- (void)setDelegate:(id<DIMConversationDelegate>)delegate {
    _delegate = delegate;
    
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
}

- (DIMConversation *)conversationWithID:(const MKMID *)ID {
    DIMConversation *chatroom = [_conversations objectForKey:ID.address];
    //NSAssert(chatroom, @"chatroom not found");
    return chatroom;
}

- (void)setConversation:(DIMConversation *)chatroom {
    MKMID *ID = chatroom.ID;
    [_conversations setObject:chatroom forKey:ID.address];
    
    // check delegate
    if (chatroom.delegate == nil) {
        chatroom.delegate = _delegate;
    }
}

@end
