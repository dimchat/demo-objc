//
//  MKMUser+History.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMConsensus.h"
#import "MKMBarrack.h"
#import "MKMBarrack+LocalStorage.h"

#import "MKMUser+History.h"

@implementation MKMUser (History)

+ (instancetype)registerWithName:(const NSString *)seed
                      privateKey:(const MKMPrivateKey *)SK
                       publicKey:(nullable const MKMPublicKey *)PK {
    NSAssert([seed length] > 0, @"seed error");
    NSAssert(!PK || [PK isMatch:SK], @"PK must match SK");
    
    // 1. create user
    MKMUser *user;
    MKMID *ID;
    MKMMeta *meta;
    // 1.1. generate meta
    meta = [[MKMMeta alloc] initWithSeed:seed privateKey:SK publicKey:PK];
    NSLog(@"register meta: %@", meta);
    // 1.2. generate ID
    ID = [meta buildIDWithNetworkID:MKMNetwork_Main];
    NSLog(@"register ID: %@", ID);
    // 1.3. create user with ID & meta
    user = [[self alloc] initWithID:ID publicKey:meta.key];
    // 1.4. store private key for user in keychain
    user.privateKey = [SK copy];
    // 1.5. add this user to entity pool
    [MKMFacebook() addUser:user];
    // 1.6. store meta & private key
    [MKMFacebook() setMeta:meta forID:ID];
    [MKMFacebook() saveMeta:meta forEntityID:ID];
    [SK saveKeyWithIdentifier:ID.address];
    
    // 2. generate history
    MKMHistory *history;
    MKMHistoryBlock *record;
    MKMHistoryTransaction *event;
    MKMHistoryOperation *op;
    // 2.1. create operation with command: "register"
    op = [[MKMHistoryOperation alloc] initWithCommand:@"register" time:nil];
    // 2.2 create event(Transaction) with operation
    event = [[MKMHistoryTransaction alloc] initWithOperation:op];
    // 2.3. create record(Block) with events
    NSData *hash = nil;
    NSData *CT = nil;
    record = [[MKMHistoryBlock alloc] initWithTransactions:@[event]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:ID];
    [record signWithPrivateKey:SK];
    // 2.4. create history with record(s)
    history = [[MKMHistory alloc] initWithID:ID];
    [history addBlock:record];
    NSLog(@"register history: %@", history);
    
    // 3. running history with delegate to update status
    [[MKMConsensus sharedInstance] runHistory:history forEntity:user];
    
    // 4. store meta + history and send out
    // 4.1. store in entity manager
//    [eman setMeta:meta forID:ID];
//    [eman setHistory:history forID:ID];
//    // 4.2. upload onto the network
//    [eman.delegate entityID:ID sendMeta:meta];
//    [eman.delegate entityID:ID sendHistory:history];
    
    // Mission Accomplished!
    NSLog(@"user account(%@) registered!", ID);
    return user;
}

- (MKMHistoryBlock *)suicideWithMessage:(const NSString *)lastWords
                             privateKey:(const MKMPrivateKey *)SK {
    NSAssert([_publicKey isMatch:SK], @"not your SK");
    
    MKMHistory *history = MKMHistoryForID(_ID);
    MKMHistoryBlock *lastBlock = history.blocks.lastObject;
    lastBlock = [MKMHistoryBlock blockWithBlock:lastBlock];
    NSData *CT = lastBlock.signature;
    NSAssert(CT, @"last block error");
    
    // 1. generate history record
    MKMHistoryBlock *record;
    MKMHistoryTransaction *ev1, *ev2;
    MKMHistoryOperation *op1, *op2;
    // 1.1. create event1(Transaction) with operation: "link"
    op1 = [[MKMHistoryOperation alloc] initWithPreviousSignature:CT time:nil];
    ev1 = [[MKMHistoryTransaction alloc] initWithOperation:op1];
    // 1.2. create event2(Transaction) with operation: "suicide"
    op2 = [[MKMHistoryOperation alloc] initWithCommand:@"suicide" time:nil];
    ev2 = [[MKMHistoryTransaction alloc] initWithOperation:op2];
    // 1.3. create record(Block) with events
    NSData *hash = nil;
    CT = nil;
    record = [[MKMHistoryBlock alloc] initWithTransactions:@[ev1, ev2]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:_ID];
    [record signWithPrivateKey:self.privateKey];
    NSLog(@"suicide record: %@", record);
    
    // 2. run history to update status
    [[MKMConsensus sharedInstance] runHistoryBlock:record forEntity:self];
    
//    // 3. store and send the history record out
//    // 3.1. store the history in entity manager
//    [eman setHistory:_history forID:_ID];
//    // 3.2. upload the new history record onto the network
//    [eman.delegate entityID:_ID sendHistoryRecord:record];
    
    // Mission Accomplished!
    NSLog(@"user account(%@) dead!", _ID);
    return record;
}

@end
