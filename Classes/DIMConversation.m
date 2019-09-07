//
//  DIMConversation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) DIMEntity *entity; // User or Group

@end

@implementation DIMConversation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMEntity *entity = nil;
    return [self initWithEntity:entity];
}

- (instancetype)initWithEntity:(DIMEntity *)entity {
    if (self = [super init]) {
        _entity = entity;
    }
    return self;
}

- (DIMConversationType)type {
    if (MKMNetwork_IsUser(_entity.type)) {
        return DIMConversationPersonal;
    } else if (MKMNetwork_IsGroup(_entity.type)) {
        return DIMConversationGroup;
    }
    return DIMConversationUnknown;
}

- (DIMID *)ID {
    return _entity.ID;
}

- (NSString *)name {
    return _entity.name;
}

- (NSString *)title {
    DIMConversationType type = self.type;
    if (type == DIMConversationPersonal) {
        DIMUser *user = (DIMUser *)_entity;
        NSString *name = user.name;
        // "xxx"
        return name;
    } else if (type == DIMConversationGroup) {
        DIMGroup *group = (DIMGroup *)_entity;
        NSString *name = group.name;
        unsigned long count = group.members.count;
        // "yyy (123)"
        return [[NSString alloc] initWithFormat:@"%@ (%lu)", name, count];
    }
    NSAssert(false, @"unknown conversation type");
    return @"Conversation";
}

- (nullable DIMProfile *)profile {
    return _entity.profile;
}

#pragma mark - Read from data source

- (NSInteger)numberOfMessage {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource numberOfMessagesInConversation:self];
}

- (DIMInstantMessage *)messageAtIndex:(NSInteger)index {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource conversation:self messageAtIndex:index];
}

- (nullable DIMInstantMessage *)lastMessage {
    NSUInteger count = [_dataSource numberOfMessagesInConversation:self];
    if (count == 0) {
        return nil;
    }
    return [_dataSource conversation:self messageAtIndex:(count - 1)];
}

#pragma mark - Write via delegate

- (BOOL)insertMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    return [_delegate conversation:self insertMessage:iMsg];
}

- (BOOL)removeMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:removeMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    return [_delegate conversation:self removeMessage:iMsg];
}

- (BOOL)withdrawMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:withdrawMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    return [_delegate conversation:self withdrawMessage:iMsg];
}

@end
