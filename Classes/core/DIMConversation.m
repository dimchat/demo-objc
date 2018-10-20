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

#import "DIMConversationDataSource.h"
#import "DIMConversationDelegate.h"

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

- (void)insertMessage:(DIMInstantMessage *)iMsg {
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
