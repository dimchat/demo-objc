//
//  MKMConsensus.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMEntity.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMAccountHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"

#import "MKMEntityManager.h"

#import "MKMConsensus.h"

//@interface MKMConsensus () {
//    
//    MKMAccountHistoryDelegate *_defaultAccountDelegate;
//    MKMGroupHistoryDelegate *_defaultGroupDelegate;
//}
//
//@end
//
//@implementation MKMConsensus
//
//SingletonImplementations(MKMConsensus, sharedInstance)
//
//- (instancetype)init {
//    if (self = [super init]) {
//        _defaultAccountDelegate = [[MKMAccountHistoryDelegate alloc] init];
//        _defaultGroupDelegate = [[MKMGroupHistoryDelegate alloc] init];
//        
//        _accountHistoryDelegate = nil;
//        _groupHistoryDelegate = nil;
//    }
//    return self;
//}
//
//#pragma mark - Entity History Delegate
//
//- (id<MKMEntityHistoryDelegate>)historyDelegateWithEntity:(const MKMEntity *)entity {
//    MKMID *ID = entity.ID;
//    MKMEntityHistoryDelegate *delegate = nil;
//    switch (ID.address.network) {
//        case MKMNetwork_Main:
//            if (_accountHistoryDelegate) {
//                delegate = _accountHistoryDelegate;
//            } else {
//                delegate = _defaultAccountDelegate;
//            }
//            break;
//            
//        case MKMNetwork_Group:
//            if (_groupHistoryDelegate) {
//                delegate = _groupHistoryDelegate;
//            } else {
//                delegate = _defaultGroupDelegate;
//            }
//            break;
//            
//        default:
//            NSAssert(false, @"network type not support");
//            break;
//    }
//    return delegate;
//}
//
//- (BOOL)recorder:(const MKMID *)ID
//  canWriteRecord:(const MKMHistoryRecord *)record
//        inEntity:(const MKMEntity *)entity {
//    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
//    id<MKMEntityHistoryDelegate> delegate;
//    delegate = [self historyDelegateWithEntity:entity];
//    return [delegate recorder:ID canWriteRecord:record inEntity:entity];
//}
//
//- (BOOL)commander:(const MKMID *)ID
//       canExecute:(const MKMHistoryOperation *)operation
//         inEntity:(const MKMEntity *)entity {
//    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
//    id<MKMEntityHistoryDelegate> delegate;
//    delegate = [self historyDelegateWithEntity:entity];
//    return [delegate commander:ID canExecute:operation inEntity:entity];
//}
//
//- (void)commander:(const MKMID *)ID
//          execute:(const MKMHistoryOperation *)operation
//         inEntity:(const MKMEntity *)entity {
//    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
//    id<MKMEntityHistoryDelegate> delegate;
//    delegate = [self historyDelegateWithEntity:entity];
//    return [delegate commander:ID execute:operation inEntity:entity];
//}
//
//@end
//
//@implementation MKMConsensus (History)
//
//- (NSUInteger)runHistory:(const MKMHistory *)history
//               forEntity:(MKMEntity *)entity {
//    NSAssert([entity.ID isValid], @"ID error");
//    NSAssert([history count] > 0, @"history cannot be empty");
//    NSUInteger pos = 0;
//    
////    // Compare the history with the old one.
////    // If they has the same record at the first place, it means
////    // the new history should have the same records with the old one,
////    // we should cut off all the exists records and just add the new ones.
////    MKMHistory * oldHis = MKMHistoryForID(entity.ID);
////
////    NSUInteger old_len = oldHis.count;
////    NSUInteger new_len = history.count;
////    if (old_len > 0 && [oldHis.firstObject isEqual:history.firstObject]) {
////        // 1. check whether new len is longer than the old len
////        if (new_len <= old_len) {
////            // all the new records must be the same with the old ones
////            // it's not necessary to check them now
////            return 0;
////        }
////        // 2. make sure the exists history is contained by the new one
////        MKMHistoryRecord *oldRec, *newRec;
////        for (pos = 1; pos < old_len; ++pos) {
////            oldRec = [oldHis objectAtIndex:pos];
////            newRec = [history objectAtIndex:pos];
////            NSAssert([oldRec isEqual:newRec], @"new record error: %@", newRec);
////            if (![oldRec isEqual:newRec]) {
////                // error
////                return 0;
////            }
////        }
////        // 3. cut off the same records, use the new records remaining
////        NSRange range = NSMakeRange(old_len, new_len - old_len);
////        NSArray *array = [history subarrayWithRange:range];
////        history = [[MKMHistory alloc] initWithArray:array];
////    }
//    
//    // OK, add new history records now
//    MKMHistoryRecord *record;
//    for (id item in history) {
//        record = [MKMHistoryRecord recordWithRecord:item];
//        if ([self runHistoryRecord:record forEntity:entity]) {
//            ++pos;
//        } else {
//            // record error
//            break;
//        }
//    }
//    
//    return pos;
//}
//
//- (BOOL)runHistoryRecord:(const MKMHistoryRecord *)record
//               forEntity:(MKMEntity *)entity {
//    // recorder
//    MKMID *recorder = record.recorder;
//    recorder = [MKMID IDWithID:recorder];
//    if (!recorder) {
//        recorder = entity.ID;
//        NSAssert(recorder.address.network == MKMNetwork_Main, @"error");
//    }
//    
//    // delegate
//    id<MKMEntityHistoryDelegate>delegate = [self historyDelegateWithEntity:entity];
//    
//    // 1. check permision for this redcorder
//    if (![delegate recorder:recorder
//             canWriteRecord:record
//                   inEntity:entity]) {
//        NSAssert(false, @"recorder permission denied");
//        return NO;
//    }
//    
//    // 2. check signature for this record
//    MKMHistory * oldHis = MKMHistoryForID(entity.ID);
//    MKMHistoryRecord *prev = oldHis.lastObject;
//    MKMPublicKey *PK = MKMPublicKeyForAccountID(recorder);
//    prev = [MKMHistoryRecord recordWithRecord:prev];
//    PK = [MKMPublicKey keyWithKey:PK];
//    if (![record verifyWithPreviousMerkle:prev.merkleRoot
//                                publicKey:PK]) {
//        NSAssert(false, @"recorder signature error");
//        return NO;
//    }
//    
//    // 3. check permission for each commander in all events
//    MKMHistoryEvent *event;
//    MKMID *commander;
//    MKMHistoryOperation *operation;
//    id op;
//    NSData *CT;
//    NSData *data;
//    for (id item in record.events) {
//        // event.commander
//        event = [MKMHistoryEvent eventWithEvent:item];
//        commander = event.commander;
//        commander = [MKMID IDWithID:commander];
//        if (!commander || [commander isEqual:recorder]) {
//            // no need to check itself
//            continue;
//        }
//        
//        // event.operation
//        op = event.operation;
//        NSAssert([op isKindOfClass:[NSString class]], @"operation must be string here");
//        operation = [MKMHistoryOperation operationWithOperation:op];
//        
//        // 3.1. check permission for this commander
//        if (![delegate commander:commander
//                      canExecute:operation
//                        inEntity:entity]) {
//            NSAssert(false, @"commander permission denied");
//            return NO;
//        }
//        
//        // event.signature
//        CT = event.signature;
//        NSAssert(CT, @"signature error");
//        data = [op data];
//        
//        // 3.2. check signature for this event
//        PK = MKMPublicKeyForAccountID(commander);
//        if (![PK verify:data withSignature:CT]) {
//            NSAssert(false, @"signature error");
//            return NO;
//        }
//    }
//    
//    // 4. execute all events in this record
//    for (id item in record.events) {
//        // event.commander
//        event = [MKMHistoryEvent eventWithEvent:item];
//        commander = event.commander;
//        if (commander) {
//            commander = [MKMID IDWithID:commander];
//        } else {
//            commander = recorder;
//        }
//        
//        // event.operation
//        op = event.operation;
//        operation = [MKMHistoryOperation operationWithOperation:op];
//        
//        // execute
//        [delegate commander:commander
//                    execute:operation
//                   inEntity:entity];
//    }
//    
//    // 5. add this record into local history
//    [oldHis addObject:record];
//    return YES;
//}
//
//@end
