//
//  MKMAccountHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMEntity.h"
#import "MKMAccount.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMAccountHistoryDelegate.h"

@implementation MKMAccountHistoryDelegate

- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record {
    // check recorder
    if (![record.recorder isEqual:entity.ID]) {
        NSAssert(false, @"only itself can write history record");
        return NO;
    }
    
    // call super check
    return [super evolvingEntity:entity canWriteRecord:record];
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
    if (![commander isEqual:entity.ID]) {
        NSAssert(false, @"only itself can run history event");
        return NO;
    }
    
    NSAssert([entity isKindOfClass:[MKMAccount class]], @"error");
    const MKMAccount *account = (const MKMAccount *)entity;
    
    MKMHistoryOperation *operation;
    operation = [MKMHistoryOperation operationWithOperation:event.operation];
    const NSString *op = operation.command;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Initialized -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            return YES;
        } else {
            return NO;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortal Accounts
        if ([commander isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [commander isEqualToString:MKM_MONKEY_KING_ID]) {
            NSAssert(false, @"immortals cannot suicide!");
            return NO;
        }
        // status: Registered -> Dead
        //if (account.status == MKMAccountStatusRegistered) {
            return YES;
        //}
    }
    
    // Account history only support TWO operations above
    return NO;
}

- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander {
    // call super execute
    [super evolvingEntity:entity execute:operation commander:commander];
    
    NSAssert([entity isKindOfClass:[MKMAccount class]], @"error");
    MKMAccount *account = (MKMAccount *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Initialized -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            account.status = MKMAccountStatusRegistered;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortal Accounts
        if ([commander isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [commander isEqualToString:MKM_MONKEY_KING_ID]) {
            NSAssert(false, @"immortals cannot suicide!");
            return ;
        }
        // status: Registered -> Dead
        //if (account.status == MKMAccountStatusRegistered) {
            account.status = MKMAccountStatusDead;
        //}
    }
}

@end
