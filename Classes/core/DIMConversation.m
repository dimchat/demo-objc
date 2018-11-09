//
//  DIMConversation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount+Message.h"
#import "MKMGroup+Message.h"

#import "DIMEnvelope.h"
#import "DIMInstantMessage.h"

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) MKMEntity *entity; // Contact or Chatroom

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
    }
    return self;
}

- (DIMConversationType)type {
    if (MKMNetwork_IsPerson(_entity.type)) {
        return DIMConversationPersonal;
    } else if (MKMNetwork_IsGroup(_entity.type)) {
        return DIMConversationGroup;
    }
    return DIMConversationUnknown;
}

- (MKMID *)ID {
    return _entity.ID;
}

- (NSString *)title {
    DIMConversationType type = self.type;
    if (type == DIMConversationPersonal) {
        MKMAccount *person = (MKMAccount *)_entity;
        NSString *name = person.name;
        // "xxx"
        return name;
    } else if (type == DIMConversationGroup) {
        MKMGroup *group = (MKMGroup *)_entity;
        NSString *name = group.name;
        NSUInteger count = group.members.count;
        // "yyy (123)"
        return [[NSString alloc] initWithFormat:@"%@ (%lu)", name, count];
    }
    NSAssert(false, @"unknown conversation type");
    return @"Conversation";
}

#pragma mark - Read

- (NSInteger)numberOfMessage {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource numberOfMessagesInConversation:self];
}

- (DIMInstantMessage *)messageAtIndex:(NSInteger)index {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource conversation:self messageAtIndex:index];
}

#pragma mark - Write

- (void)insertMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    [_delegate conversation:self didReceiveMessage:iMsg];
}

- (void)removeMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    if ([_delegate respondsToSelector:@selector(conversation:removeMessage:)]) {
        [_delegate conversation:self removeMessage:iMsg];
    }
}

- (void)withdrawMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    if ([_delegate respondsToSelector:@selector(conversation:withdrawMessage:)]) {
        [_delegate conversation:self withdrawMessage:iMsg];
    }
}

@end
