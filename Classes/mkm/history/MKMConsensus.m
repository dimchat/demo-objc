//
//  MKMConsensus.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMEntity.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMAccountHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"

#import "MKMBarrack.h"

#import "MKMConsensus.h"

static id<MKMEntityHistoryDelegate>history_delegate(const MKMEntity *entity) {
    MKMNetworkType network = entity.ID.address.network;
    MKMEntityHistoryDelegate *delegate = nil;
    switch (network) {
        case MKMNetwork_Main:
            delegate = [MKMConsensus sharedInstance].accountHistoryDelegate;
            break;
            
        case MKMNetwork_Group:
            delegate = [MKMConsensus sharedInstance].groupHistoryDelegate;
            break;
            
        default:
            break;
    }
    assert(delegate);
    return delegate;
}

@interface MKMConsensus () {
    
    MKMAccountHistoryDelegate *_defaultAccountDelegate;
    MKMGroupHistoryDelegate *_defaultGroupDelegate;
}

@end

@implementation MKMConsensus

SingletonImplementations(MKMConsensus, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _defaultAccountDelegate = [[MKMAccountHistoryDelegate alloc] init];
        _defaultGroupDelegate = [[MKMGroupHistoryDelegate alloc] init];
        
        _accountHistoryDelegate = nil;
        _groupHistoryDelegate = nil;
    }
    return self;
}

- (id<MKMEntityHistoryDelegate>)accountHistoryDelegate {
    if (_accountHistoryDelegate) {
        return _accountHistoryDelegate;
    } else {
        return _defaultAccountDelegate;
    }
}

- (id<MKMEntityHistoryDelegate>)groupHistoryDelegate {
    if (_groupHistoryDelegate) {
        return _groupHistoryDelegate;
    } else {
        return _defaultGroupDelegate;
    }
}

#pragma mark - MKMEntityHistoryDelegate

- (BOOL)historyRecorder:(const MKMID *)recorder
          canWriteBlock:(const MKMHistoryBlock *)record
               inEntity:(const MKMEntity *)entity {
    NSAssert(recorder.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate historyRecorder:recorder
                       canWriteBlock:record
                            inEntity:entity];
}

- (BOOL)historyCommander:(const MKMID *)commander
              canExecute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity {
    NSAssert(commander.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate historyCommander:commander
                           canExecute:operation
                             inEntity:entity];
}

- (void)historyCommander:(const MKMID *)commander
                 execute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity {
    NSAssert(commander.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate historyCommander:commander
                              execute:operation
                             inEntity:entity];
}

@end

@implementation MKMConsensus (History)

- (NSUInteger)runHistory:(const MKMHistory *)history
               forEntity:(MKMEntity *)entity {
    NSAssert([entity.ID isValid], @"ID error");
    NSAssert([history count] > 0, @"history cannot be empty");
    NSUInteger pos = 0;
    
//    // Compare the history with the old one.
//    // If they has the same record at the first place, it means
//    // the new history should have the same records with the old one,
//    // we should cut off all the exists records and just add the new ones.
//    MKMHistory * oldHis = MKMHistoryForID(entity.ID);
//
//    NSUInteger old_len = oldHis.count;
//    NSUInteger new_len = history.count;
//    if (old_len > 0 && [oldHis.firstObject isEqual:history.firstObject]) {
//        // 1. check whether new len is longer than the old len
//        if (new_len <= old_len) {
//            // all the new records must be the same with the old ones
//            // it's not necessary to check them now
//            return 0;
//        }
//        // 2. make sure the exists history is contained by the new one
//        MKMHistoryRecord *oldRec, *newRec;
//        for (pos = 1; pos < old_len; ++pos) {
//            oldRec = [oldHis objectAtIndex:pos];
//            newRec = [history objectAtIndex:pos];
//            NSAssert([oldRec isEqual:newRec], @"new record error: %@", newRec);
//            if (![oldRec isEqual:newRec]) {
//                // error
//                return 0;
//            }
//        }
//        // 3. cut off the same records, use the new records remaining
//        NSRange range = NSMakeRange(old_len, new_len - old_len);
//        NSArray *array = [history subarrayWithRange:range];
//        history = [[MKMHistory alloc] initWithArray:array];
//    }
    
    // OK, add new history records now
    MKMHistoryBlock *record, *prev = nil;
    for (id item in history) {
        record = [MKMHistoryBlock blockWithBlock:item];
        // check the link with previous record
        if (prev && ![record.previousSignature isEqualToData:prev.signature]) {
            NSAssert(false, @"blocks not linked");
            break;
        }
        // run this record
        if ([self runHistoryBlock:record forEntity:entity]) {
            ++pos;
        } else {
            // record error
            break;
        }
        prev = record;
    }
    
    return pos;
}

- (BOOL)runHistoryBlock:(const MKMHistoryBlock *)record
              forEntity:(MKMEntity *)entity {
    // recorder
    MKMID *recorder = record.recorder;
    recorder = [MKMID IDWithID:recorder];
    if (!recorder) {
        recorder = entity.ID;
        NSAssert(recorder.address.network == MKMNetwork_Main, @"error");
    }
    
    // 1. check signature for this record
    MKMPublicKey *PK = MKMPublicKeyForID(recorder);
    if (![PK verify:record.merkleRoot withSignature:record.signature]) {
        NSAssert(false, @"signature error");
        return NO;
    }
    
    // 2. check permision for this redcorder
    if (![self historyRecorder:recorder canWriteBlock:record inEntity:entity]) {
        NSAssert(false, @"recorder permission denied");
        return NO;
    }
    
    // 3. check permission for each commander in all events
    MKMHistoryTransaction *event;
    MKMID *commander;
    MKMHistoryOperation *operation;
    id op;
    NSData *CT;
    NSData *data;
    for (id item in record.transactions) {
        // event.commander
        event = [MKMHistoryTransaction transactionWithTransaction:item];
        commander = event.commander;
        commander = [MKMID IDWithID:commander];
        if (!commander || [commander isEqual:recorder]) {
            // no need to check itself
            continue;
        }
        
        // event.operation
        op = event.operation;
        NSAssert([op isKindOfClass:[NSString class]],
                 @"operation must be string here");
        operation = [MKMHistoryOperation operationWithOperation:op];
        
        // 3.1. check permission for this commander
        if (![self historyCommander:commander
                         canExecute:operation
                           inEntity:entity]) {
            NSAssert(false, @"commander permission denied");
            return NO;
        }
        
        // event.signature
        CT = event.signature;
        NSAssert(CT, @"signature error");
        data = [op data];
        
        // 3.2. check signature for this event
        PK = MKMPublicKeyForID(commander);
        if (![PK verify:data withSignature:CT]) {
            NSAssert(false, @"signature error");
            return NO;
        }
    }
    
    // 4. execute all events in this record
    for (id item in record.transactions) {
        // event.commander
        event = [MKMHistoryTransaction transactionWithTransaction:item];
        commander = event.commander;
        if (commander) {
            commander = [MKMID IDWithID:commander];
        } else {
            commander = recorder;
        }
        
        // event.operation
        op = event.operation;
        operation = [MKMHistoryOperation operationWithOperation:op];
        
        // execute
        [self historyCommander:commander execute:operation inEntity:entity];
    }
    
    return YES;
}

@end
