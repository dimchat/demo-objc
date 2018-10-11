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

#import "MKMEntityManager.h"

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

- (instancetype)initWithID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (!meta) {
        // get meta info
        MKMEntityManager *em = [MKMEntityManager sharedManager];
        meta = [em metaWithID:ID];
    }
    
    if (self = [super init]) {
        BOOL correct;
        // ID
        correct = ID.isValid;
        NSAssert(correct, @"ID error");
        if (correct) {
            _ID = [ID copy];
        }
        
        // meta
        correct = [ID checkMeta:meta];
        NSAssert(correct, @"meta error");
        if (correct) {
            _meta = [meta copy];
        }
        
        // history
        _history = [[MKMHistory alloc] init];
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

- (NSUInteger)number {
    return _ID.address.code;
}

@end
