//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMProfile.h"
#import "MKMBarrack.h"

#import "MKMEntity.h"

@implementation MKMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *ID = nil;
    self = [self initWithID:ID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID {
    if (self = [super init]) {
        NSAssert([ID isValid], @"Invalid ID");
        _ID = [ID copy];
        _name = nil; // lazy
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMEntity *entity = [[self class] allocWithZone:zone];
    entity = [entity initWithID:_ID];
    if (entity) {
        entity.name = _name;
    }
    return entity;
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
    }
    // profile.name
    MKMProfile *profile = MKMProfileForID(_ID);
    NSString *nick = profile.name;
    if (nick) {
        return nick;
    }
    // ID.name
    return _ID.name;
}

@end
