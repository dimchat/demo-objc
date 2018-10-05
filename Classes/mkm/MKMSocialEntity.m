//
//  MKMSocialEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMSocialEntity.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) const MKMMeta *meta;
@property (strong, nonatomic) const MKMHistory *history;

@end

@interface MKMSocialEntity ()

@property (strong, nonatomic) const NSString *name;

@property (strong, nonatomic) const MKMID *founder;
@property (strong, nonatomic) const MKMID *owner;

@end

@implementation MKMSocialEntity

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _members = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addMember:(const MKMID *)ID {
    if ([self containsMember:ID]) {
        return;
    }
    [_members addObject:ID];
}

- (void)removeMember:(const MKMID *)ID {
    if (![self containsMember:ID]) {
        return;
    }
    [_members removeObject:ID];
}

- (BOOL)containsMember:(const MKMID *)ID {
    return [_members containsObject:ID];
}

@end

@implementation MKMSocialEntity (HistoryDelegate)

- (BOOL)commander:(const MKMID *)ID
       canDoEvent:(const MKMHistoryEvent *)event
         inEntity:(const MKMEntity *)entity {
    if (![super commander:ID canDoEvent:event inEntity:entity]) {
        return NO;
    }
    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
    MKMSocialEntity *se = (MKMSocialEntity *)entity;
    
    const NSString *op = event.operation.operate;
    if ([op isEqualToString:@"found"] ||
        [op isEqualToString:@"create"]) {
        // founder
        if (se.history.count > 0) {
            NSAssert(false, @"only the first record");
            return NO;
        }
        if (![ID.publicKey isEqual:entity.meta.key]) {
            NSAssert(false, @"only founder can do this");
            return NO;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        // owner
        if (![ID isEqual:se.owner]) {
            NSAssert(false, @"only owner can do this");
            return NO;
        }
    }
    
    // allow all members to write history record,
    // let the subclass to reduce it
    BOOL isMember = NO;
    MKMID *member;
    for (id item in se.members) {
        // member
        member = [MKMID IDWithID:item];
        if ([member isEqual:ID]) {
            isMember = YES;
            break;
        }
    }
    NSAssert(isMember, @"must be a member");
    if (!isMember) {
        return NO;
    }
    
    // let the subclass to extend the permission control
    return YES;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    [super commander:ID execute:operation inEntity:entity];
    
    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
    MKMSocialEntity *se = (MKMSocialEntity *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"found"] ||
        [op isEqualToString:@"create"]) {
        // founder
        MKMID *founder = [operation objectForKey:@"founder"];
        if (founder) {
            NSAssert(!se.founder, @"founder error");
            founder = [MKMID IDWithID:founder];
            NSAssert(founder, @"error");
            se.founder = founder;
            se.owner = founder; // also the first owner
        }
        // first owner
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            NSAssert(!_owner, @"owner error");
            owner = [MKMID IDWithID:owner];
            NSAssert(owner, @"error");
            se.owner = owner;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        // abdicate the ownership
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            NSAssert(_owner, @"owner error");
            owner = [MKMID IDWithID:owner];
            NSAssert(owner, @"error");
            se.owner = owner;
        }
    } else if ([op isEqualToString:@"invite"]) {
        // invite user
        MKMID *user = [operation objectForKey:@"user"];
        if (!user) {
            user = [operation objectForKey:@"member"];
        }
        if (user) {
            user = [MKMID IDWithID:user];
            NSAssert(user, @"error");
            [se addMember:user];
        }
    } else if ([op isEqualToString:@"expel"]) {
        // expel member
        MKMID *user = [operation objectForKey:@"member"];
        if (user) {
            user = [MKMID IDWithID:user];
            NSAssert(user, @"error");
            [se removeMember:user];
        }
    } else if ([op isEqualToString:@"join"]) {
        // join
        [se addMember:ID];
    } else if ([op isEqualToString:@"quit"]) {
        // quit
        [se removeMember:ID];
    } else if ([op isEqualToString:@"name"] ||
               [op isEqualToString:@"setName"]) {
        // set name
        NSString *name = [operation objectForKey:@"name"];
        if (name) {
            se.name = name;
        }
    }
}

@end
