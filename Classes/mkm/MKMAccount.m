//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMProfile.h"

#import "MKMAccount.h"

@implementation MKMAccount

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMProfile alloc] init];
    }
    
    return self;
}

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

@end

@implementation MKMAccount (HistoryDelegate)

- (BOOL)commander:(const MKMID *)ID
       canDoEvent:(const MKMHistoryEvent *)event
         inEntity:(const MKMEntity *)entity {
    if (![super commander:ID canDoEvent:event inEntity:entity]) {
        return NO;
    }
    if (![entity.ID isEqual:ID]) {
        NSAssert(false, @"only itself can do the event");
        return NO;
    }
    
    const NSString *op = event.operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        if (_status == MKMAccountStatusInitialized) {
            return YES;
        } else {
            return NO;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // status: Registerd -> Dead
        if (_status == MKMAccountStatusRegistered) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    [super commander:ID execute:operation inEntity:entity];
    
    const NSString *op = operation.operate;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Init -> Registered
        NSAssert(_status == MKMAccountStatusInitialized, @"status error");
        _status = MKMAccountStatusRegistered;
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // status: Registerd -> Dead
        NSAssert(_status == MKMAccountStatusRegistered, @"status error");
        _status = MKMAccountStatusDead;
    }
}

@end
