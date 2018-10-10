//
//  MKMEntity+History.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMPerson.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMEntityHistoryDelegate.h"

#import "MKMEntity+History.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) const MKMMeta *meta;

@end

@implementation MKMEntity (History)

- (NSUInteger)runHistory:(const MKMHistory *)history {
    NSAssert(_ID, @"ID error");
    NSAssert(self.meta, @"meta error");
    NSAssert([history count] > 0, @"history cannot be empty");
    NSUInteger pos = 0;
    
    // Compare the history with the old one.
    // If they has the same record at the first place, it means
    // the new history should have the same records with the old one,
    // we should cut off all the exists records and just add the new ones.
    
    NSUInteger old_len = _history.count;
    NSUInteger new_len = history.count;
    if (old_len > 0 && [_history.firstObject isEqual:history.firstObject]) {
        // 1. check whether new len is longer than the old len
        if (new_len <= old_len) {
            // all the new records must be the same with the old ones
            // it's not necessary to check them now
            return 0;
        }
        // 2. make sure the exists history is contained by the new one
        MKMHistoryRecord *oldRec, *newRec;
        for (pos = 1; pos < old_len; ++pos) {
            oldRec = [_history objectAtIndex:pos];
            newRec = [history objectAtIndex:pos];
            NSAssert([oldRec isEqual:newRec], @"new record error: %@", newRec);
            if (![oldRec isEqual:newRec]) {
                // error
                return 0;
            }
        }
        // 3. cut off the same records, use the new records remaining
        NSRange range = NSMakeRange(old_len, new_len - old_len);
        NSArray *array = [history subarrayWithRange:range];
        history = [[MKMHistory alloc] initWithArray:array];
    }
    
    // OK, add new history records now
    MKMHistoryRecord *record;
    for (id item in history) {
        record = [MKMHistoryRecord recordWithRecord:item];
        if ([self runHistoryRecord:record]) {
            ++pos;
        } else {
            // record error
            break;
        }
    }
    
    return pos;
}

- (BOOL)runHistoryRecord:(const MKMHistoryRecord *)record {
    // recorder
    const MKMID *recorder = record.recorder;
    recorder = [MKMID IDWithID:recorder];
    if (!recorder) {
        NSAssert([self isKindOfClass:[MKMPerson class]], @"error");
        recorder = _ID;
    }
    
    // 1. check permision for this redcorder
    if (![self.historyDelegate recorder:recorder
                         canWriteRecord:record
                               inEntity:self]) {
        NSAssert(false, @"recorder permission denied");
        return NO;
    }
    
    // 2. check signature for this record
    MKMHistoryRecord *prev = _history.lastObject;
    const MKMPublicKey *PK = recorder.publicKey;
    prev = [MKMHistoryRecord recordWithRecord:prev];
    PK = [MKMPublicKey keyWithKey:PK];
    if (![record verifyWithPreviousMerkle:prev.merkleRoot
                                publicKey:PK]) {
        NSAssert(false, @"recorder signature error");
        return NO;
    }
    
    // 3. check permission for each commander in all events
    MKMHistoryEvent *event;
    const MKMID *commander;
    MKMHistoryOperation *operation;
    id op;
    const NSData *CT;
    NSData *data;
    for (id item in record.events) {
        // event.commander
        event = [MKMHistoryEvent eventWithEvent:item];
        commander = event.commander;
        commander = [MKMID IDWithID:commander];
        if (!commander || [commander isEqual:recorder]) {
            // no need to check itself
            continue;
        }
        
        // event.operation
        op = event.operation;
        NSAssert([op isKindOfClass:[NSString class]], @"operation must be string here");
        operation = [MKMHistoryOperation operationWithOperation:op];
        
        // 3.1. check permission for this commander
        if (![self.historyDelegate commander:commander
                                  canExecute:operation
                                    inEntity:self]) {
            NSAssert(false, @"commander permission denied");
            return NO;
        }
        
        // event.signature
        CT = event.signature;
        NSAssert(CT, @"signature error");
        data = [op data];
        
        // 3.2. check signature for this event
        PK = commander.publicKey;
        if (![PK verify:data signature:CT]) {
            NSAssert(false, @"signature error");
            return NO;
        }
    }
    
    // 4. execute all events in this record
    for (id item in record.events) {
        // event.commander
        event = [MKMHistoryEvent eventWithEvent:item];
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
        [self.historyDelegate commander:commander
                                execute:operation
                               inEntity:self];
    }
    
    // 5. add this record into local history
    [_history addObject:record];
    return YES;
}

@end
