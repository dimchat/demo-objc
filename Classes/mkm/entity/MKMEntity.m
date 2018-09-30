//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMEntity.h"

@interface MKMEntity ()

@property (strong, nonatomic) const MKMID *ID;
@property (strong, nonatomic) const MKMMeta *meta;

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
    if ([self checkHistoryRecord:record]) {
        [_history addObject:record];
        return YES;
    }
    return NO;
}

- (BOOL)checkHistoryRecord:(const MKMHistoryRecord *)record {
    // 1. verify signature
    MKMHistoryRecord *prev = _history.lastObject;
    BOOL correct = [record verifyWithPreviousMerkle:prev.merkleRoot publicKey:_ID.publicKey];
    NSAssert(correct, @"history record incorrect");
    if (!correct) {
        // history record error
        return NO;
    }
    
    // 2. do other checking in subclass
    
    return YES;
}

@end
