//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistory.h"

#import "MKMConsensus.h"

#import "MKMEntity.h"

@interface MKMEntity ()

@property (strong, nonatomic) MKMID *ID;
@property (strong, nonatomic) MKMMeta *meta;
@property (strong, nonatomic) MKMHistory *history;

@end

@implementation MKMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *ID = nil;
    MKMMeta *meta = nil;
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    NSAssert([ID isValid], @"Invalid ID");
    if (self = [super init]) {
        // ID
        if (ID.isValid) {
            _ID = [ID copy];
        }
        
        // meta
        if ([meta matchID:ID]) {
            _meta = [meta copy];
        }
        
        // history
        _history = [[MKMHistory alloc] init];
        // delegate
        _historyDelegate = [MKMConsensus sharedInstance];
    }
    
    return self;
}

- (id)copy {
    MKMEntity *entity = [[[self class] alloc] initWithID:_ID meta:_meta];
    if (entity) {
        entity.history = _history;
        entity.historyDelegate = _historyDelegate;
    }
    return entity;
}

- (BOOL)isEqual:(id)object {
    MKMEntity *entity = (MKMEntity *)object;
    
    // check ID
    if (![entity.ID isEqual:_ID]) {
        return NO;
    }
    
    // check meta
    if (![entity.meta isEqual:_meta]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)number {
    return _ID.number;
}

@end
