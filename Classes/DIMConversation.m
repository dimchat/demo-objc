//
//  DIMConversation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) DIMEntity *entity; // Account or Group

@end

@implementation DIMConversation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMEntity *entity = nil;
    self = [self initWithEntity:entity];
    return self;
}

- (instancetype)initWithEntity:(const DIMEntity *)entity {
    if (self = [super init]) {
        _entity = [entity copy];
    }
    return self;
}

- (DIMConversationType)type {
    if (MKMNetwork_IsCommunicator(_entity.type)) {
        return DIMConversationPersonal;
    } else if (MKMNetwork_IsGroup(_entity.type)) {
        return DIMConversationGroup;
    }
    return DIMConversationUnknown;
}

- (const DIMID *)ID {
    return _entity.ID;
}

- (NSString *)name {
    return _entity.name;
}

- (NSString *)title {
    DIMConversationType type = self.type;
    if (type == DIMConversationPersonal) {
        DIMAccount *person = (DIMAccount *)_entity;
        NSString *name = person.name;
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

#pragma mark - Read from data source

- (NSInteger)numberOfMessage {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource numberOfMessagesInConversation:self];
}

- (DIMInstantMessage *)messageAtIndex:(NSInteger)index {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource conversation:self messageAtIndex:index];
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
