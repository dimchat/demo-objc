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

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMAccountHistoryDelegate.h"

@interface MKMAccount (Hacking)

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccountHistoryDelegate

- (BOOL)recorder:(const MKMID *)ID
  canWriteRecord:(const MKMHistoryRecord *)record
        inEntity:(const MKMEntity *)entity {
    // call super check
    if (![super recorder:ID canWriteRecord:record inEntity:entity]) {
        return NO;
    }
    
    if (![entity.ID isEqual:ID]) {
        NSAssert(false, @"only itself can write history record");
        return NO;
    }
    
    return YES;
}

- (BOOL)commander:(const MKMID *)ID
       canExecute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // call super check
    if (![super commander:ID canExecute:operation inEntity:entity]) {
        return NO;
    }
    
    if (![entity.ID isEqual:ID]) {
        NSAssert(false, @"only itself can execute operation");
        return NO;
    }
    
    NSAssert([entity isKindOfClass:[MKMAccount class]], @"error");
    const MKMAccount *account = (const MKMAccount *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            return YES;
        } else {
            return NO;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortal Accounts
        if ([ID isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [ID isEqualToString:MKM_MONKEY_KING_ID]) {
            NSAssert(false, @"immortals cannot suicide!");
            return NO;
        }
        // status: Registerd -> Dead
        if (account.status == MKMAccountStatusRegistered) {
            return YES;
        } else {
            return NO;
        }
    }
    
    // Account history only support TWO operations above
    return NO;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // call super execute
    [super commander:ID execute:operation inEntity:entity];
    
    NSAssert([entity isKindOfClass:[MKMAccount class]], @"error");
    const MKMAccount *account = (const MKMAccount *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            account.status = MKMAccountStatusRegistered;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // status: Registerd -> Dead
        if (account.status == MKMAccountStatusRegistered) {
            account.status = MKMAccountStatusDead;
        }
    }
}

@end
