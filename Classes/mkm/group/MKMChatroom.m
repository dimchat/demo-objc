//
//  MKMChatroom.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMChatroom.h"

@interface MKMChatroom ()

@property (strong, nonatomic) MKMAdminListM *administrators;

@end

@implementation MKMChatroom

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 founderID:(const MKMID *)founderID {
    NSAssert(ID.type == MKMNetwork_Chatroom, @"ID error");
    if (self = [super initWithID:ID founderID:founderID]) {
        // lazy
        _administrators = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMChatroom *chatroom = [super copyWithZone:zone];
    if (chatroom) {
        chatroom.administrators = _administrators;
    }
    return chatroom;
}

- (void)removeMember:(const MKMID *)ID {
    if ([self isOwner:ID]) {
        NSAssert(false, @"owner cannot be remove, abdicate first");
        return;
    }
    if ([self isAdmin:ID]) {
        NSAssert(false, @"admin cannot be remove, fire/resign first");
        return;
    }
    [super removeMember:ID];
}

- (void)addAdmin:(const MKMID *)ID {
    if ([self isAdmin:ID]) {
        // don't add the same admin twice
        return;
    }
    if (![self isMember:ID]) {
        NSAssert(false, @"should be a member first");
        [self addMember:ID];
    }
    if (!_administrators) {
        _administrators = [[MKMAdminListM alloc] init];
    }
    [_administrators addObject:ID];
}

- (void)removeAdmin:(const MKMID *)ID {
    NSAssert([self isAdmin:ID], @"no such admin found");
    [_administrators removeObject:ID];
}

- (BOOL)isAdmin:(const MKMID *)ID {
    if ([_administrators containsObject:ID]) {
        NSAssert([self isMember:ID], @"should be a member too");
        return YES;
    }
    return NO;
}

@end
