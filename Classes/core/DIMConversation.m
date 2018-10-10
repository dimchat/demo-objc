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
    return pos;
}

@end
