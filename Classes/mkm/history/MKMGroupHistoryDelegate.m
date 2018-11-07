//
//  MKMGroupHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMGroup.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"

#import "MKMGroupHistoryDelegate.h"

@implementation MKMGroupHistoryDelegate

- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record {
    // call super check
    if (![super evolvingEntity:entity canWriteRecord:record]) {
        return NO;
    }
    
    MKMID *recorder = [MKMID IDWithID:record.recorder];
    NSAssert([recorder isValid], @"recorder error");
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
    MKMGroup *group = (MKMGroup *)entity;
    
    BOOL isOwner = [group isOwner:recorder];
    if (isOwner) {
        return YES;
    }
    
    // only the owner can write history for group
    return NO;
}

- (BOOL)evolvingEntity:(const MKMEntity *)entity
           canRunEvent:(const MKMHistoryTransaction *)event
              recorder:(const MKMID *)recorder {
    // call super check
    if (![super evolvingEntity:entity canRunEvent:event recorder:recorder]) {
        return NO;
    }
    
    // check commander
    const MKMID *commander = event.commander;
    if (!commander) {
        commander = recorder;
    }
    
    MKMHistoryOperation *operation = event.operation;
    operation = [MKMHistoryOperation operationWithOperation:operation];
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
    MKMGroup *group = (MKMGroup *)entity;
    
    //BOOL isFounder = [group isFounder:ID];
    BOOL isOwner = [group isOwner:commander];
    BOOL isAdmin = [group isAdmin:commander];
    //BOOL isMember = isOwner || isAdmin || [group isMember:ID];
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"name"] ||
        [op isEqualToString:@"setName"]) {
        // let the subclass to reduce it
    } else if ([op isEqualToString:@"invite"]) {
        // let the subclass to reduce it
    } else if ([op isEqualToString:@"expel"]) {
        // owner or admin
        if (!isOwner && !isAdmin) {
            NSAssert(false, @"only owner or admin can expel member");
            return NO;
        }
    } else if ([op isEqualToString:@"hire"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can hire admin");
            return NO;
        }
    } else if ([op isEqualToString:@"fire"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can fire admin");
            return NO;
        }
    } else if ([op isEqualToString:@"resign"]) {
        // only admin
        if (!isAdmin || isOwner) {
            NSAssert(false, @"only admin can resign");
            return NO;
        }
    } else if ([op isEqualToString:@"quit"]) {
        // the super has forbidden the owner to quit directly
        // here forbid the admin too
        if (isAdmin) {
            NSAssert(false, @"admin cannot quit, resign first");
            return NO;
        }
    }
    
    // let the subclass to extend the permission list
    return YES;
}

- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander {
    // call super execute
    [super evolvingEntity:entity execute:operation commander:commander];
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
    MKMGroup *group = (MKMGroup *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"hire"]) {
        NSAssert([group isOwner:commander], @"permission denied");
        // hire admin
        MKMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [MKMID IDWithID:admin];
            [group addAdmin:admin];
        }
    } else if ([op isEqualToString:@"fire"]) {
        NSAssert([group isOwner:commander], @"permission denied");
        // fire admin
        MKMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [MKMID IDWithID:admin];
            [group removeAdmin:admin];
        }
    } else if ([op isEqualToString:@"resign"]) {
        NSAssert([group isAdmin:commander], @"history error");
        // resign admin
        [group removeAdmin:commander];
    }
}

@end
