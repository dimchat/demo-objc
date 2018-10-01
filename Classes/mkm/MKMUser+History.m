//
//  MKMUser+History.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMUser+History.h"

@implementation MKMUser (History)

+ (instancetype)registerWithName:(const NSString *)seed
                       publicKey:(const MKMPublicKey *)PK
                      privateKey:(const MKMPrivateKey *)SK {
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
    MKMUser *user = [[self alloc] initWithID:ID meta:meta];
    NSInteger count = [user runHistory:history];
    NSAssert([history count] == count, @"history error");
    
    // 5. send the ID+meta+history out
    
    // TODO: pack and send
    
    return user;
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
    
    // 2. send the record out
    
    // TODO: pack and send
    
    return his;
}

@end
