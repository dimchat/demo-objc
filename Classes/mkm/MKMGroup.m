//
//  MKMGroup.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMHistory.h"

#import "MKMEntity+History.h"
#import "MKMGroupHistoryDelegate.h"
#import "MKMEntityManager.h"

#import "MKMGroup.h"

@interface MKMSocialEntity (Hacking)

- (void)addMember:(const MKMID *)ID;
- (void)removeMember:(const MKMID *)ID;

@end

@implementation MKMGroup

+ (instancetype)groupWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Group, @"addr error");
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMMeta *meta = [em metaWithID:ID];
    MKMHistory *history = [em historyWithID:ID];
    MKMGroup *group = [[self alloc] initWithID:ID meta:meta];
    if (group) {
        MKMGroupHistoryDelegate *delegate;
        delegate = [[MKMGroupHistoryDelegate alloc] init];
        group.historyDelegate = delegate;
        NSUInteger count = [group runHistory:history];
        NSAssert(count == history.count, @"history error");
        NSAssert(group.owner, @"owner cannot be empty");
        NSAssert(group.members.count > 0, @"members error");
    }
    return group;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _administrators = [[NSMutableArray alloc] init];
    }
    
    return self;
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
        return;
    }
    if (![self isMember:ID]) {
        NSAssert(false, @"should be a member first");
        [self addMember:ID];
    }
    [_administrators addObject:ID];
}

- (void)removeAdmin:(const MKMID *)ID {
    if (![self isAdmin:ID]) {
        return;
    }
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
