//
//  DIMUser+History.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMUser+History.h"

//@implementation DIMUser (History)
//
//+ (instancetype)registerWithName:(const NSString *)seed
//                       publicKey:(const MKMPublicKey *)PK
//                      privateKey:(const MKMPrivateKey *)SK {
//    NSAssert([seed length] > 0, @"seed error");
//    NSAssert([PK isMatch:SK], @"PK must match SK");
//    
//    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
//    
//    // 1. create user
//    DIMUser *user;
//    MKMID *ID;
//    MKMAddress *address;
//    MKMMeta *meta;
//    // 1.1. generate meta
//    meta = [[MKMMeta alloc] initWithSeed:seed publicKey:PK privateKey:SK];
//    NSLog(@"register meta: %@", meta);
//    // 1.2. generate address with meta info
//    address = [meta buildAddressWithNetworkID:MKMNetwork_Main];
//    // 1.3. generate ID
//    ID = [[MKMID alloc] initWithName:seed address:address];
//    NSLog(@"register ID: %@", ID);
//    // 1.4. create user with ID & meta
//    user = [[self alloc] initWithID:ID publicKey:meta.key];
//    // 1.5. store private key for user in keychain
//    user.privateKey = [SK copy];
//    // 1.6. store the meta for user in entity manager
//    [eman setMeta:meta forID:ID];
//    
//    // 2. generate history
//    MKMHistory *history;
//    NSArray *records;
//    MKMHistoryRecord *record;
//    NSData *CT = nil;
//    NSData *hash = nil;
//    NSArray *events;
//    MKMHistoryEvent *evt;
//    MKMHistoryOperation *op;
//    // 2.1. create history.record.event.operation with operate: "register"
//    op = [[MKMHistoryOperation alloc] initWithOperate:@"register"];
//    // 2.2 create history.record.event with operation
//    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
//    // 2.2. create history.record with events
//    events = [NSArray arrayWithObject:evt];
//    record = [[MKMHistoryRecord alloc] initWithEvents:events
//                                               merkle:hash
//                                            signature:CT];
//    // 2.3. sign this record with private key
//    [record signWithPreviousMerkle:hash privateKey:SK];
//    records = [NSArray arrayWithObject:record];
//    // 2.4. create history with record(s)
//    history = [[MKMHistory alloc] initWithArray:records];
//    NSLog(@"register history: %@", history);
//    
//    // 3. running history with delegate to update status
//    
//    // 4. store meta + history and send out
//    // 4.1. store the history in entity manager
//    [eman setHistory:history forID:ID];
//    // 4.2. upload the meta & history onto the network
//    [eman.delegate entityID:ID sendMeta:meta];
//    [eman.delegate entityID:ID sendHistory:history];
//    
//    // Mission Accomplished!
//    NSLog(@"user account(%@) registered!", ID);
//    return user;
//}
//
//- (MKMHistoryRecord *)suicideWithMessage:(const NSString *)lastWords
//                              privateKey:(const MKMPrivateKey *)SK {
//    NSAssert([_publicKey isMatch:SK], @"not your SK");
//    
//    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
//    
//    // 1. generate history record
//    MKMHistoryRecord *record;
//    NSData *CT = nil;
//    NSData *hash = nil;
//    NSArray *events;
//    MKMHistoryEvent *evt;
//    MKMHistoryOperation *op;
//    // 1.1. create history.record.event.operation with operate: "suicide"
//    op = [[MKMHistoryOperation alloc] initWithOperate:@"suicide"];
//    // 1.2. create history.record.event with operation
//    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
//    // 1.3. create history.record with events
//    events = [NSArray arrayWithObject:evt];
//    record = [[MKMHistoryRecord alloc] initWithEvents:events
//                                               merkle:hash
//                                            signature:CT];
//    // 1.4. sign with previous merkle root
//    MKMHistory *oldHis = MKMHistoryForID(self.ID);
//    MKMHistoryRecord *prev = oldHis.lastObject;
//    [record signWithPreviousMerkle:prev.merkleRoot privateKey:SK];
//    NSLog(@"suicide record: %@", record);
//    
//    // 2. run history to update status
//    
//    // 3. store and send the history record out
//    // 3.1. store the history in entity manager
////    [eman setHistory:_history forID:_ID];
//    // 3.2. upload the new history record onto the network
//    [eman.delegate entityID:_ID sendHistoryRecord:record];
//    
//    // Mission Accomplished!
//    NSLog(@"user account(%@) dead!", _ID);
//    return record;
//}
//
//@end
