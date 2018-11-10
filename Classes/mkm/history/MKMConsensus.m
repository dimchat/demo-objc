//
//  MKMConsensus.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMEntity.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMAccountHistoryDelegate.h"
#import "MKMChatroomHistoryDelegate.h"

#import "MKMConsensus.h"

static inline id history_delegate(const MKMEntity *entity) {
    MKMNetworkType network = entity.ID.address.network;
    MKMEntityHistoryDelegate *delegate = nil;
    if (MKMNetwork_IsPerson(network)) {
        delegate = [MKMConsensus sharedInstance].accountHistoryDelegate;
    } else if (MKMNetwork_IsGroup(network)) {
        delegate = [MKMConsensus sharedInstance].groupHistoryDelegate;
    }
    assert(delegate);
    return delegate;
}

@interface MKMConsensus () {
    
    MKMAccountHistoryDelegate *_defaultAccountDelegate;
    MKMChatroomHistoryDelegate *_defaultChatroomDelegate;
}

@end

@implementation MKMConsensus

SingletonImplementations(MKMConsensus, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _defaultAccountDelegate = [[MKMAccountHistoryDelegate alloc] init];
        _defaultChatroomDelegate = [[MKMChatroomHistoryDelegate alloc] init];
        
        _accountHistoryDelegate = nil;
        _groupHistoryDelegate = nil;
        
        _entityHistoryDataSource = nil;
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
        return _defaultChatroomDelegate;
    }
}

#pragma mark - MKMEntityHistoryDelegate

- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record {
    NSAssert(MKMNetwork_IsPerson(record.recorder.type), @"recorder error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity canWriteRecord:record];
}

- (BOOL)evolvingEntity:(const MKMEntity *)entity
           canRunEvent:(const MKMHistoryTransaction *)event
              recorder:(const MKMID *)recorder {
    NSAssert(!event.commander || MKMNetwork_IsPerson(event.commander.type),
             @"commander error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity canRunEvent:event recorder:recorder];
}

- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander {
    NSAssert(MKMNetwork_IsPerson(commander.type), @"ID error");
    id<MKMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity execute:operation commander:commander];
}

#pragma mark - MKMEntityHistoryDataSource

- (MKMHistory *)historyForEntityID:(const MKMID *)ID {
    NSAssert(_entityHistoryDataSource, @"entity history data source not set");
    return [_entityHistoryDataSource historyForEntityID:ID];
}

@end

@implementation MKMConsensus (History)

- (NSUInteger)runHistory:(const MKMHistory *)history
               forEntity:(MKMEntity *)entity {
    NSAssert([entity.ID isValid], @"ID error");
    NSAssert([history.ID isEqual:entity.ID], @"ID not match");
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
    for (id item in history.blocks) {
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
    // 1. get recorder
    MKMID *recorder = record.recorder;
    recorder = [MKMID IDWithID:recorder];
    if (!recorder) {
        NSAssert(MKMNetwork_IsPerson(entity.type), @"error");
        recorder = entity.ID;
    }
    
    // 2. check permision for this recorder
    if (![self evolvingEntity:entity canWriteRecord:record]) {
        NSAssert(false, @"recorder permission denied");
        return NO;
    }
    
    // 3. check permission for each commander in all events
    MKMHistoryTransaction *event;
    for (id item in record.transactions) {
        // 3.1. get commander
        event = [MKMHistoryTransaction transactionWithTransaction:item];
        
        // 3.2. check permission for this commander
        if (![self evolvingEntity:entity canRunEvent:event recorder:recorder]) {
            NSAssert(false, @"commander permission denied");
            return NO;
        }
    }
    
    // 4. execute all events in this record
    MKMHistoryOperation *op;
    MKMID *commander;
    for (id item in record.transactions) {
        // event.commander
        event = [MKMHistoryTransaction transactionWithTransaction:item];
        commander = event.commander;
        if (!commander) {
            commander = recorder;
        }
        
        // event.operation
        op = [MKMHistoryOperation operationWithOperation:event.operation];
        
        // execute
        [self evolvingEntity:entity execute:op commander:commander];
    }
    
    return YES;
}

@end
