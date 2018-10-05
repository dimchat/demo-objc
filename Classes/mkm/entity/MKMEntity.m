//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMAccount.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMEntity.h"

@interface MKMEntity ()

@property (strong, nonatomic) const MKMID *ID;
@property (strong, nonatomic) const MKMMeta *meta;
@property (strong, nonatomic) const MKMHistory *history;

@end

@implementation MKMEntity

- (instancetype)init {
    // TODO: prepare test account (hulk@xxx) which cannot suiside
    const MKMID *ID = nil;
    const MKMMeta *meta = nil;
    self = [self initWithID:ID meta:meta];
    return self;
}

- (instancetype)initWithID:(const MKMID *)ID {
    const MKMMeta *meta = nil;
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super init]) {
        BOOL correct;
        // ID
        correct = ID.isValid;
        NSAssert(correct, @"ID error");
        if (correct) {
            self.ID = ID;
        }
        
        // meta
        correct = [ID checkMeta:meta];
        NSAssert(correct, @"meta error");
        if (correct) {
            self.meta = meta;
        }
        
        // history
        _history = [[MKMHistory alloc] init];
    }
    
    return self;
}

- (NSUInteger)number {
    return _ID.address.code;
}

- (BOOL)recorder:(const MKMID *)ID
  canWriteRecord:(const MKMHistoryRecord *)record
        inEntity:(const MKMEntity *)entity {
    NSAssert(!record.recorder || [record.recorder isEqual:ID], @"error");
    
    // check signature
    MKMHistoryRecord *prev = entity.history.lastObject;
    const MKMPublicKey *PK = ID.publicKey;
    if (![record verifyWithPreviousMerkle:prev.merkleRoot
                                publicKey:PK]) {
        NSAssert(false, @"signature error");
        return NO;
    }
    
    // check events
    MKMHistoryEvent *event;
    const MKMID *commander;
    for (id item in record.events) {
        event = [MKMHistoryEvent eventWithEvent:item];
        commander = event.commander;
        if (!commander || [commander isEqual:ID]) {
            // no need to check itself
            continue;
        }
        
        // check commander's permission
        if (![self commander:commander
                  canDoEvent:event
                    inEntity:entity]) {
            NSAssert(false, @"event permission denied: %@", event);
            return NO;
        }
    }
    
    // let the subclass to define the recorder's permission
    return YES;
}

- (BOOL)commander:(const MKMID *)ID
       canDoEvent:(const MKMHistoryEvent *)event
         inEntity:(const MKMEntity *)entity {
    NSAssert(!event.commander || [event.commander isEqual:ID], @"error");
    
    // check the signature
    const MKMPublicKey *PK = ID.publicKey;
    const NSData *CT = event.signature;
    if (CT) {
        NSAssert(event.commander, @"error");
        id operation = event.operation;
        NSAssert([operation isKindOfClass:[NSString class]], @"error");
        NSData *data = [operation data];
        if (![PK verify:data signature:CT]) {
            NSAssert(false, @"signature error");
            return NO;
        }
    }
    
    // let the subclass to define the commander's permission
    return YES;
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    // let the subclass to execute the operation
}

@end

@implementation MKMEntity (History)

- (NSUInteger)runHistory:(const MKMHistory *)history {
    NSAssert(_ID, @"ID error");
    NSAssert(_meta, @"meta error");
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
    for (id item in history) {
        if ([self runHistoryRecord:item]) {
            ++pos;
        } else {
            // record error
            break;
        }
    }
    
    return pos;
}

- (BOOL)runHistoryRecord:(const MKMHistoryRecord *)record {
    if (![self checkHistoryRecord:record]) {
        // history error
        return NO;
    }
    
    const MKMID *ID = record.recorder;
    if (!ID) {
        NSAssert([self isKindOfClass:[MKMAccount class]], @"error");
        ID = _ID;
    }
    
    // execute operation in the event
    MKMHistoryEvent *event;
    const MKMID *commander;
    for (id item in record.events) {
        event = [MKMHistoryEvent eventWithEvent:item];
        commander = event.commander;
        if (!commander) {
            commander = ID;
        }
        [_historyDelegate commander:commander
                            execute:event.operation
                           inEntity:self];
    }
    
    [_history addObject:record];
    return YES;
}

- (BOOL)checkHistoryRecord:(const MKMHistoryRecord *)record {
    const MKMID *ID = record.recorder;
    if (!ID) {
        NSAssert([self isKindOfClass:[MKMAccount class]], @"error");
        ID = _ID;
    }
    
    // check recorder's permission
    if (![_historyDelegate recorder:ID
                     canWriteRecord:record
                           inEntity:self]) {
        NSAssert(false, @"record permission denied");
        return NO;
    }
    
    return YES;
}

@end
