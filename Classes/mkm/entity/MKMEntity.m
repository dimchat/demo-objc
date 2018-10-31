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

#import "MKMEntity.h"

@implementation MKMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *ID = nil;
    MKMMeta *meta = nil;
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID meta:(const MKMMeta *)meta {
    if (self = [super init]) {
        // ID
        NSAssert([ID isValid], @"Invalid ID");
        _ID = [ID copy];
        
        // meta
        NSAssert([meta matchID:ID], @"meta error");
        _meta = [meta copy];
    }
    
    return self;
}

- (id)copy {
    return [[[self class] alloc] initWithID:_ID meta:_meta];
}

- (BOOL)isEqual:(id)object {
    MKMEntity *entity = (MKMEntity *)object;
    NSAssert([entity.ID isValid], @"Invalid ID");
    return [entity.ID isEqual:_ID];
}

- (MKMNetworkType)type {
    return _ID.type;
}

- (UInt32)number {
    return _ID.number;
}

- (NSString *)name {
    if (_name) {
        return _name;
    } else {
        return _ID.name;
    }
}

@end
