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

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccount

- (const MKMPublicKey *)publicKey {
    return self.ID.publicKey;
}

- (NSUInteger)number {
    return self.ID.number;
}

+ (instancetype)registerWithName:(const NSString *)seed publicKey:(const MKMPublicKey *)PK privateKey:(const MKMPrivateKey *)SK {
    NSAssert([seed length] > 2, @"seed error");
    NSAssert([PK isMatch:SK], @"PK must match SK");
    
    // 1. generate meta
    MKMMeta *meta;
    meta = [[MKMMeta alloc] initWithSeed:seed publicKey:PK privateKey:SK];
    NSLog(@"register meta: %@", meta);
    
    MKMAddress *address;
    address = [[MKMAddress alloc] initWithFingerprint:meta.fingerprint
                                              network:MKMNetwork_Main
                                              version:MKMAddressDefaultVersion];
    
    // 2. generate ID
    MKMID *ID = [[MKMID alloc] initWithName:seed address:address];
    NSLog(@"register ID: %@", ID);
    
    // 3. generate history
    MKMHistory *history;
    MKMHistoryRecord *his;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    op = [[MKMHistoryOperation alloc] initWithOperate:@"register"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    his = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [his signWithPreviousMerkle:hash privateKey:SK];
    NSArray *records = [NSArray arrayWithObject:his];
    history = [[MKMHistory alloc] initWithArray:records];
    NSLog(@"register history: %@", history);
    
    // 4. create
    return [[[self class] alloc] initWithID:ID
                                       meta:meta
                                    history:history];
}

- (MKMHistoryRecord *)suicideWithMessage:(const NSString *)lastWords
                              privateKey:(const MKMPrivateKey *)SK {
    // 1. generate history record
    MKMHistoryRecord *his;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    op = [[MKMHistoryOperation alloc] initWithOperate:@"suicide"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    his = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [his signWithPreviousMerkle:hash privateKey:SK];
    
    // 2. send the record
    
    // TODO: pack and send
    
    return his;
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
