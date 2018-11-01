//
//  MKMSocialEntityHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMEntity.h"
#import "MKMSocialEntity.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMSocialEntityHistoryDelegate.h"

//@interface MKMEntity (Hacking)
//
//@property (strong, nonatomic) NSString *name;
//
//@end
//
//@interface MKMSocialEntity (Hacking)
//
//@property (strong, nonatomic) MKMID *founder;
//@property (strong, nonatomic) MKMID *owner;
//
//- (void)addMember:(const MKMID *)ID;
//- (void)removeMember:(const MKMID *)ID;
//
//@end
//
//@implementation MKMSocialEntityHistoryDelegate
//
//- (BOOL)recorder:(const MKMID *)ID
//  canWriteRecord:(const MKMHistoryRecord *)record
//        inEntity:(const MKMEntity *)entity {
//    // call super check
//    if (![super recorder:ID canWriteRecord:record inEntity:entity]) {
//        return NO;
//    }
//    
//    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
//    MKMSocialEntity *social = (MKMSocialEntity *)entity;
//    
//    BOOL isOwner = [social isOwner:ID];
//    BOOL isMember = [social isMember:ID];
//    
//    // 1. owner
//    if (isOwner) {
//        // owner can do anything!
//        return YES;
//    }
//    
//    // 2. member
//    if (isMember) {
//        // allow all members to write history record,
//        // let the subclass to reduce it
//        return YES;
//    }
//    
//    // 3. others
//    if (!isOwner && !isMember) {
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
//    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
//    MKMSocialEntity *social = (MKMSocialEntity *)entity;
//    
//    BOOL isFounder = [social isFounder:ID];
//    BOOL isOwner = [social isOwner:ID];
//    BOOL isMember = isOwner || [social isMember:ID];
//    
//    const NSString *op = operation.operate;
//    // first record
//    if (social.history.count == 0) {
//        if ([op isEqualToString:@"found"] ||
//            [op isEqualToString:@"create"]) {
//            // only founder
//            if (!isFounder) {
//                NSAssert(false, @"only founder can create");
//                return NO;
//            }
//        } else {
//            NSAssert(false, @"first record must be found");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"abdicate"]) {
//        // only owner
//        if (!isOwner) {
//            NSAssert(false, @"only owner can abdicate");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"name"] ||
//               [op isEqualToString:@"setName"]) {
//        // all members
//        //    let the subclass to reduce it
//        if (!isMember) {
//            NSAssert(false, @"who are you?");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"invite"]) {
//        // all members
//        //    let the subclass to reduce it
//        if (!isMember) {
//            NSAssert(false, @"who are you?");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"expel"]) {
//        // all members
//        //    let the subclass to reduce it
//        if (!isMember) {
//            NSAssert(false, @"who are you?");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"join"]) {
//        // others
//        if (isMember) {
//            NSAssert(false, @"you are already a member");
//            return NO;
//        }
//    } else if ([op isEqualToString:@"quit"]) {
//        // all members except owner
//        //    forbide the owner to quit directly
//        if (!isMember || isOwner) {
//            NSAssert(false, @"owner cannot quit, abdicate first");
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
//    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
//    MKMSocialEntity *social = (MKMSocialEntity *)entity;
//    
//    const NSString *op = operation.operate;
//    if ([op isEqualToString:@"found"] ||
//        [op isEqualToString:@"create"]) {
//        NSAssert(social.history.count == 0, @"only first record");
//        NSAssert([social isFounder:ID], @"permission denied");
//        // founder
//        MKMID *founder = [operation extraInfoForKey:@"founder"];
//        if (founder) {
//            NSAssert(!social.founder, @"founder error");
//            NSAssert(!social.owner, @"owner error");
//            founder = [MKMID IDWithID:founder];
//            social.founder = founder;
//            social.owner = founder; // also the first owner
//        }
//        // first owner
//        MKMID *owner = [operation extraInfoForKey:@"owner"];
//        if (owner) {
//            NSAssert(!social.owner, @"owner error");
//            owner = [MKMID IDWithID:owner];
//            social.owner = owner;
//        }
//    } else if ([op isEqualToString:@"abdicate"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        NSAssert([social isOwner:ID], @"permission denied");
//        // abdicate the ownership
//        MKMID *owner = [operation extraInfoForKey:@"owner"];
//        if (owner) {
//            owner = [MKMID IDWithID:owner];
//            social.owner = owner;
//        }
//    } else if ([op isEqualToString:@"invite"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        // invite user to member
//        MKMID *user = [operation extraInfoForKey:@"user"];
//        if (!user) {
//            user = [operation extraInfoForKey:@"member"];
//        }
//        if (user) {
//            user = [MKMID IDWithID:user];
//            [social addMember:user];
//        }
//    } else if ([op isEqualToString:@"expel"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        // expel member
//        MKMID *member = [operation extraInfoForKey:@"member"];
//        if (member) {
//            member = [MKMID IDWithID:member];
//            [social removeMember:member];
//        }
//    } else if ([op isEqualToString:@"join"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        // join
//        [social addMember:ID];
//    } else if ([op isEqualToString:@"quit"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        // quit
//        [social removeMember:ID];
//    } else if ([op isEqualToString:@"name"] ||
//               [op isEqualToString:@"setName"]) {
//        NSAssert(social.history.count > 0, @"history error");
//        // set name
//        NSString *name = [operation extraInfoForKey:@"name"];
//        if (name) {
//            social.name = name;
//        }
//    }
//}
//
//@end
