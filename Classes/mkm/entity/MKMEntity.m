//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMEntity.h"

@interface MKMEntity ()

@property (strong, nonatomic) const MKMID *ID;
@property (strong, nonatomic) const MKMMeta *meta;
@property (strong, nonatomic) const MKMHistory *history;

@property (nonatomic) BOOL isValid;

@end

@implementation MKMEntity

- (instancetype)init {
    // TODO: prepare test account
    const MKMID *ID = nil;
    const MKMMeta *meta = nil;
    const MKMHistory *history = nil;
    self = [self initWithID:ID meta:meta history:history];
    return self;
}

- (instancetype)initWithID:(const MKMID *)ID {
    const MKMMeta *meta = nil;
    const MKMHistory *history = nil;
    self = [self initWithID:ID meta:meta history:history];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
                   history:(const MKMHistory *)history {
    if (self = [super init]) {
        self.ID = ID;
        self.meta = meta;
        self.history = [[MKMHistory alloc] init];
        
        // 1. check ID & meta
        self.isValid = [self analyse];
        
        // 2. run history
        if (_isValid && meta && history) {
            [self runHistory:history];
        }
    }
    
    return self;
}

- (BOOL)analyse {
    // check ID
    if (_ID.isValid == NO) {
        // ID error
        return NO;
    }
    
    // check meta
    if (_meta && ([_ID checkMeta:_meta] == NO)) {
        // meta error
        return NO;
    }
    
    return YES;
}

- (NSUInteger)runHistory:(const MKMHistory *)history {
    NSUInteger pos = 0;
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
    BOOL correct = [record verifyWithPreviousMerkle:prev.merkleRoot publicKey:self.ID.publicKey];
    NSAssert(correct, @"history record incorrect");
    if (!correct) {
        // history record error
        return NO;
    }
    
    // 2. do other checking in subclass
    
    return YES;
}

@end
