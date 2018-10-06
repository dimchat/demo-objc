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

@end
