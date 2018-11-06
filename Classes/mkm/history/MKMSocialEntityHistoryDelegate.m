//
//  MKMSocialEntityHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMEntity.h"
#import "MKMSocialEntity.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMBarrack.h"

#import "MKMSocialEntityHistoryDelegate.h"

@interface MKMSocialEntity (Hacking)

@property (strong, nonatomic) MKMID *founder;

@end

@implementation MKMSocialEntityHistoryDelegate

- (BOOL)recorder:(const MKMID *)ID
   canWriteBlock:(const MKMHistoryBlock *)record
        inEntity:(const MKMEntity *)entity {
    // call super check
    if (![super recorder:ID canWriteBlock:record inEntity:entity]) {
        return NO;
    }
    
    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
    MKMSocialEntity *social = (MKMSocialEntity *)entity;
    MKMMemberList *members = social.members;
    NSAssert(members.count > 0, @"members cannot be empty");
    
    // check member confirms for each transaction
    for (id tx in record.transactions) {
        NSInteger confirms = 1; // include the recorder as default
        MKMHistoryTransaction *event;
        event = [MKMHistoryTransaction transactionWithTransaction:tx];
        for (MKMAddress *addr in event.confirmations) {
            if ([ID.address isEqualToString:addr]) {
                // the recorder not need to confirm, skip it
                continue;
            }
            for (id m in members) {
                MKMID *mid = [MKMID IDWithID:m];
                if ([mid.address isEqualToString:addr]) {
                    // address match a member
                    NSData *CT = [event confirmationForID:mid];
                    MKMPublicKey *PK = MKMPublicKeyForID(mid);
                    if ([PK verify:record.signature withSignature:CT]) {
                        ++confirms;
                    } else {
                        NSAssert(false, @"confirmation error");
                    }
                }
            }
        }
        if (confirms * 2 <= members.count) {
            NSAssert(false, @"confirmations not enough for %@", tx);
            return NO;
        }
    }
    
    BOOL isOwner = [social isOwner:ID];
    BOOL isMember = [social isMember:ID];
    
    // 1. owner
    if (isOwner) {
        // owner can do anything!
        return YES;
    }
    
    // 2. member
    if (isMember) {
        // allow all members to write history record,
        // let the subclass to reduce it
        return YES;
    }
    
    // 3. others
    if (!isOwner && !isMember) {
        // if someone want to join the social entity,
        // he must ask the owner or any member to help
        // to write a record in the history
        return NO;
    }
    
    // let the subclass to extend the permission control
    return YES;
}

- (BOOL)commander:(const MKMID *)ID
       canExecute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // call super check
    if (![super commander:ID canExecute:operation inEntity:entity]) {
        return NO;
    }
    
    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
    MKMSocialEntity *social = (MKMSocialEntity *)entity;
    
    BOOL isOwner = [social isOwner:ID];
    BOOL isMember = isOwner || [social isMember:ID];
    
    const NSString *op = operation.command;
    // first record
    if (social.founder == nil) {
        if ([op isEqualToString:@"found"] ||
            [op isEqualToString:@"create"]) {
            // only founder
            MKMMeta *meta = MKMMetaForID(social.ID);
            MKMPublicKey *PK = MKMPublicKeyForID(ID);
            if (![meta.key isEqual:PK]) {
                NSAssert(false, @"only founder can create");
                return NO;
            }
        } else {
            NSAssert(false, @"first record must be found");
            return NO;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can abdicate");
            return NO;
        }
    } else if ([op isEqualToString:@"name"] ||
               [op isEqualToString:@"setName"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            NSAssert(false, @"who are you?");
            return NO;
        }
    } else if ([op isEqualToString:@"invite"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            NSAssert(false, @"who are you?");
            return NO;
        }
    } else if ([op isEqualToString:@"expel"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            NSAssert(false, @"who are you?");
            return NO;
        }
    } else if ([op isEqualToString:@"join"]) {
        // others
        if (isMember) {
            NSAssert(false, @"you are already a member");
            return NO;
        }
    } else if ([op isEqualToString:@"quit"]) {
        // all members except owner
        //    forbide the owner to quit directly
        if (!isMember || isOwner) {
            NSAssert(false, @"owner cannot quit, abdicate first");
            return NO;
        }
    }
    
    // let the subclass to extend the permission list
    return YES;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // call super execute
    [super commander:ID execute:operation inEntity:entity];
    
    NSAssert([entity isKindOfClass:[MKMSocialEntity class]], @"error");
    MKMSocialEntity *social = (MKMSocialEntity *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"found"] ||
        [op isEqualToString:@"create"]) {
        // founder
        MKMID *founder = [operation objectForKey:@"founder"];
        NSAssert(founder, @"history error");
        founder = [MKMID IDWithID:founder];
        NSAssert(!social.founder || [social.founder isEqual:founder],
                 @"founder error");
        social.founder = founder;
        
        // first owner
        NSAssert(!social.owner, @"owner error");
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            owner = [MKMID IDWithID:owner];
            social.owner = owner;
        } else {
            // founder is the first owner as default
            social.owner = founder;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        NSAssert(social.founder, @"history error");
        NSAssert([social isOwner:ID], @"permission denied");
        // abdicate the ownership
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            owner = [MKMID IDWithID:owner];
            social.owner = owner;
        }
    } else if ([op isEqualToString:@"invite"]) {
        NSAssert(social.founder, @"history error");
        // invite user to member
        MKMID *user = [operation objectForKey:@"user"];
        if (!user) {
            user = [operation objectForKey:@"member"];
        }
        if (user) {
            user = [MKMID IDWithID:user];
            [social addMember:user];
        }
    } else if ([op isEqualToString:@"expel"]) {
        NSAssert(social.founder, @"history error");
        // expel member
        MKMID *member = [operation objectForKey:@"member"];
        if (member) {
            member = [MKMID IDWithID:member];
            [social removeMember:member];
        }
    } else if ([op isEqualToString:@"join"]) {
        NSAssert(social.founder, @"history error");
        // join
        [social addMember:ID];
    } else if ([op isEqualToString:@"quit"]) {
        NSAssert(social.founder, @"history error");
        // quit
        [social removeMember:ID];
    } else if ([op isEqualToString:@"name"] ||
               [op isEqualToString:@"setName"]) {
        NSAssert(social.founder, @"history error");
        // set name
        NSString *name = [operation objectForKey:@"name"];
        if (name) {
            social.name = name;
        }
    }
}

@end
