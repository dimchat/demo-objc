//
//  MKMPersonHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMEntity.h"
#import "MKMPerson.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMPersonHistoryDelegate.h"

@interface MKMPerson (Hacking)

@property (nonatomic) MKMPersonStatus status;

@end

@implementation MKMPersonHistoryDelegate

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
    
    NSAssert([entity isKindOfClass:[MKMPerson class]], @"error");
    const MKMPerson *person = (const MKMPerson *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        if (person.status == MKMPersonStatusInitialized) {
            return YES;
        } else {
            return NO;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortals
        if ([ID isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [ID isEqualToString:MKM_MONKEY_KING_ID]) {
            // cannot suicide!
            return NO;
        }
        // status: Registerd -> Dead
        if (person.status == MKMPersonStatusRegistered) {
            return YES;
        } else {
            return NO;
        }
    }
    
    // Person history only support TWO operations above
    return NO;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // call super execute
    [super commander:ID execute:operation inEntity:entity];
    
    NSAssert([entity isKindOfClass:[MKMPerson class]], @"error");
    const MKMPerson *person = (const MKMPerson *)entity;
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        if (person.status == MKMPersonStatusInitialized) {
            person.status = MKMPersonStatusRegistered;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // status: Registerd -> Dead
        if (person.status == MKMPersonStatusRegistered) {
            person.status = MKMPersonStatusDead;
        }
    }
}

@end
