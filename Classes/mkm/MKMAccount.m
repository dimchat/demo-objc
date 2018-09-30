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
    return self.ID.publicKey;
}

- (BOOL)checkHistoryRecord:(const MKMHistoryRecord *)record {
    if (![super checkHistoryRecord:record]) {
        // error
        return NO;
    }
    
    // check events.operate
    id event;
    const NSString *op;
    for (event in record.events) {
        if (![event isKindOfClass:[MKMHistoryEvent class]]) {
            if ([event isKindOfClass:[NSString class]]) {
                event = [[MKMHistoryEvent alloc] initWithJSONString:event];
            } else if ([event isKindOfClass:[NSDictionary class]]) {
                event = [[MKMHistoryEvent alloc] initWithDictionary:event];
            } else {
                event = nil;
            }
        }
        op = ((MKMHistoryEvent *)event).operation.operate;
        if ([op isEqualToString:@"create"] ||
            [op isEqualToString:@"register"]) {
            // status: Init -> Registered
            NSAssert(_status == MKMAccountStatusInitialized, @"status error");
            if (_status == MKMAccountStatusInitialized) {
                _status = MKMAccountStatusRegistered;
            } else {
                // status error
                return NO;
            }
        } else if ([op isEqualToString:@"destroy"] ||
                   [op isEqualToString:@"suicide"]) {
            // status: Registerd -> Dead
            NSAssert(_status == MKMAccountStatusRegistered, @"status error");
            if (_status == MKMAccountStatusRegistered) {
                _status = MKMAccountStatusDead;
            } else {
                // status error
                return NO;
            }
        } else {
            // operate error
            return NO;
        }
    }
    
    return YES;
}

@end
