//
//  DIMConversation.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) MKMEntity *entity; // Account or Group

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

- (BOOL)insertMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    return [_delegate conversation:self insertMessage:iMsg];
}

- (BOOL)removeMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:removeMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    return [_delegate conversation:self removeMessage:iMsg];
}

- (BOOL)withdrawMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:withdrawMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    return [_delegate conversation:self withdrawMessage:iMsg];
}

@end
