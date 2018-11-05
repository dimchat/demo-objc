//
//  MKMGroupHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMGroup.h"

#import "MKMGroupHistoryDelegate.h"

//@interface MKMGroup (Hacking)
//
//- (void)addAdmin:(const MKMID *)ID;
//- (void)removeAdmin:(const MKMID *)ID;
//
//@end
//
//@implementation MKMGroupHistoryDelegate
//
//- (BOOL)recorder:(const MKMID *)ID
//  canWriteRecord:(const MKMHistoryRecord *)record
//        inEntity:(const MKMEntity *)entity {
//    // call super check
//    if (![super recorder:ID canWriteRecord:record inEntity:entity]) {
//        return NO;
//    }
//    
//    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
//    MKMGroup *group = (MKMGroup *)entity;
//    
//    BOOL isOwner = [group isOwner:ID];
//    BOOL isAdmin = [group isAdmin:ID];
//    BOOL isMember = [group isMember:ID];
//    
//    // 1. owner
//    if (isOwner) {
//        // owner can do anything!
//        return YES;
//    }
//    
//    // 2. admin
//    if (isAdmin) {
//        
//        return YES;
//    }
//    
//    // 3. member
//    if (isMember) {
//        // allow all members to write history record,
//        // let the subclass to reduce it
//        return YES;
//    }
//    
//    // 4. others
//    if (!isOwner && !isAdmin && !isMember) {
//        // if someone want to join the social entity,
//        // he must ask the owner or any member to help
//        // to write a record in the history
//        return NO;
//    }
//    
//    // let the subclass to extend the permission control
//    return YES;
//}
//
//- (BOOL)commander:(const MKMID *)ID
//       canExecute:(const MKMHistoryOperation *)operation
//         inEntity:(const MKMEntity *)entity {
//    // call super check
//    if (![super commander:ID canExecute:operation inEntity:entity]) {
//        return NO;
//    }
//    
//    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
//    MKMGroup *group = (MKMGroup *)entity;
//    
//    //BOOL isFounder = [group isFounder:ID];
//    BOOL isOwner = [group isOwner:ID];
//    BOOL isAdmin = [group isAdmin:ID];
//    //BOOL isMember = isOwner || isAdmin || [group isMember:ID];
//    
//    const NSString *op = operation.operate;
//    if ([op isEqualToString:@"name"] ||
//        [op isEqualToString:@"setName"]) {
//        // let the subclass to reduce it
//    } else if ([op isEqualToString:@"invite"]) {
//        // let the subclass to reduce it
//    } else if ([op isEqualToString:@"expel"]) {
//        // owner or admin
//        if (!isOwner && !isAdmin) {
//            NSAssert(false, @"only owner or admin can expel member");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"hire"]) {
//        // only owner
//        if (!isOwner) {
//            NSAssert(false, @"only owner can hire admin");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"fire"]) {
//        // only owner
//        if (!isOwner) {
//            NSAssert(false, @"only owner can fire admin");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"resign"]) {
//        // only admin
//        if (!isAdmin || isOwner) {
//            NSAssert(false, @"only admin can resign");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"quit"]) {
//        // the super has forbidden the owner to quit directly
//        // here forbid the admin too
//        if (isAdmin) {
//            NSAssert(false, @"admin cannot quit, resign first");
//            return NO;
//        }
//    }
//    
//    // let the subclass to extend the permission list
//    return YES;
//}
//
//- (void)commander:(const MKMID *)ID
//          execute:(const MKMHistoryOperation *)operation
//         inEntity:(const MKMEntity *)entity {
//    // call super execute
//    [super commander:ID execute:operation inEntity:entity];
//    
//    NSAssert([entity isKindOfClass:[MKMGroup class]], @"error");
//    MKMGroup *group = (MKMGroup *)entity;
//    
//    const NSString *op = operation.operate;
//    if ([op isEqualToString:@"hire"]) {
//        // hire admin
//        MKMID *admin = [operation extraInfoForKey:@"admin"];
//        if (!admin) {
//            admin = [operation extraInfoForKey:@"administrator"];
//        }
//        if (admin) {
//            admin = [MKMID IDWithID:admin];
//            [group addAdmin:admin];
//        }
//    } else if ([op isEqualToString:@"fire"]) {
//        // fire admin
//        MKMID *admin = [operation extraInfoForKey:@"admin"];
//        if (!admin) {
//            admin = [operation extraInfoForKey:@"administrator"];
//        }
//        if (admin) {
//            admin = [MKMID IDWithID:admin];
//            [group removeAdmin:admin];
//        }
//    } else if ([op isEqualToString:@"resign"]) {
//        // resign admin
//        [group removeAdmin:ID];
//    }
//}
//
//@end
