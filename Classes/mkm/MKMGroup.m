//
//  MKMGroup.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMGroup.h"

@implementation MKMGroup

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _administrators = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addAdmin:(const MKMID *)ID {
    if ([self containsAdmin:ID]) {
        return;
    }
    [_administrators addObject:ID];
}

- (void)removeAdmin:(const MKMID *)ID {
    if (![self containsAdmin:ID]) {
        return;
    }
    [_administrators removeObject:ID];
}

- (BOOL)containsAdmin:(const MKMID *)ID {
    return [_administrators containsObject:ID];
}

@end

@implementation MKMGroup (HistoryDelegate)

- (BOOL)commander:(const MKMID *)ID
       canDoEvent:(const MKMHistoryEvent *)event
         inEntity:(const MKMEntity *)entity {
    if (![super commander:ID canDoEvent:event inEntity:entity]) {
        return NO;
    }
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
    MKMGroup *group = (MKMGroup *)entity;
    
    BOOL isOwner = [group.owner isEqual:ID];
    BOOL isAdmin = [group containsAdmin:ID];
    
    const NSString *op = event.operation.operate;
    if ([op isEqualToString:@"expel"]) {
        if (!isOwner && !isAdmin) {
            // only the owner/admin can do this
            return NO;
        }
    } else if ([op isEqualToString:@"hire"]) {
        // hire admin
        if (!isOwner) {
            // only the owner can do this
            return NO;
        }
    } else if ([op isEqualToString:@"fire"]) {
        // fire admin
        if (!isOwner) {
            // only the owner can do this
            return NO;
        }
    } else if ([op isEqualToString:@"resign"]) {
        // resign
        if (isOwner || !isAdmin) {
            // only the admin can do this
            return NO;
        }
    }
    
    // let the subclass to extend the permission control
    return YES;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    [super commander:ID execute:operation inEntity:entity];
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
    MKMGroup *group = (MKMGroup *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"hire"]) {
        // hire admin
        MKMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [MKMID IDWithID:admin];
            NSAssert(admin, @"error");
            [group addAdmin:admin];
        }
    } else if ([op isEqualToString:@"fire"]) {
        // fire admin
        MKMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [MKMID IDWithID:admin];
            NSAssert(admin, @"error");
            [group removeAdmin:admin];
        }
    } else if ([op isEqualToString:@"resign"]) {
        // resign
        [group removeMember:ID];
    }
}

@end
