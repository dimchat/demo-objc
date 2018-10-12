//
//  DIMUser+History.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMKeyStore.h"

#import "DIMUser+History.h"

@implementation DIMUser (History)

+ (instancetype)registerWithName:(const NSString *)seed
                       publicKey:(const MKMPublicKey *)PK
                      privateKey:(const MKMPrivateKey *)SK {
    NSAssert([seed length] > 2, @"seed error");
    NSAssert([PK isMatch:SK], @"PK must match SK");
    
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    
    // 1. create user
    // 1.1. generate meta
    MKMMeta *meta;
    meta = [[MKMMeta alloc] initWithSeed:seed publicKey:PK privateKey:SK];
    NSLog(@"register meta: %@", meta);
    // 1.2. generate address with meta info
    MKMAddress *address;
    address = [meta buildAddressWithNetworkID:MKMNetwork_Main];
    // 1.3. generate ID
    MKMID *ID = [[MKMID alloc] initWithName:seed address:address];
    NSLog(@"register ID: %@", ID);
    // 1.4. create user with ID & meta
    DIMUser *user = [[self alloc] initWithID:ID meta:meta];
    // 1.5. store the meta in entity manager
    [eman setMeta:meta forID:ID];
    
    // 2. generate history
    MKMHistory *history;
    MKMHistoryRecord *his;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    // 2.1. create event.operation
    op = [[MKMHistoryOperation alloc] initWithOperate:@"register"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    // 2.2. create history.record
    his = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [his signWithPreviousMerkle:hash privateKey:SK];
    NSArray *records = [NSArray arrayWithObject:his];
    history = [[MKMHistory alloc] initWithArray:records];
    NSLog(@"register history: %@", history);
    
    // 3. update status by running history record
    user.historyDelegate = [MKMConsensus sharedInstance];
    NSInteger count = [user runHistory:history];
    
    if ([history count] == count) {
        // 3.1. store the history in entity manager
        [eman setHistory:history forID:ID];
        
        // 3.2. upload the meta & history onto the network
        [eman.delegate postMeta:meta history:history forID:ID];
        
        // 3.3. store the private key in key store
        [store setPrivateKey:[SK copy] forUser:user];
        
        return user;
    }
    
    NSAssert(false, @"register failed");
    return nil;
}

- (MKMHistoryRecord *)suicideWithMessage:(const NSString *)lastWords
                              privateKey:(const MKMPrivateKey *)SK {
    NSAssert([self matchPrivateKey:SK], @"not your SK");
    
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    
    // 1. generate history record
    MKMHistoryRecord *record;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    op = [[MKMHistoryOperation alloc] initWithOperate:@"suicide"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    record = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [record signWithPreviousMerkle:hash privateKey:SK];
    NSLog(@"suicide record: %@", record);
    
    // 2. send the history record out
    BOOL OK = [self runHistoryRecord:record];
    if (OK) {
        // 2.1. store the history in entity manager
        [eman setHistory:_history forID:_ID];
        
        // 2.2. upload the new history record onto the network
        [eman.delegate postHistoryRecord:record forID:_ID];
        
        return record;
    }
    
    NSAssert(false, @"suicide failed");
    return nil;
}

@end
