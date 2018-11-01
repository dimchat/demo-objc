//
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

@interface MKMID ()

@property (strong, nonatomic, nonnull) NSString *name;
@property (strong, nonatomic, nonnull) MKMAddress *address;

@property (strong, nonatomic, nullable) NSString *terminal;

@property (nonatomic, getter=isValid) BOOL valid;

@end

static void parse_id_string(const NSString *string, MKMID *ID) {
    // get terminal
    NSArray *pair = [string componentsSeparatedByString:@"/"];
    if (pair.count == 2) {
        string = pair.firstObject; // drop the tail
        ID.terminal = pair.lastObject;
    }
    
    pair = [string componentsSeparatedByString:@"@"];
    assert(pair.count == 2);
    
    // get name
    ID.name = [pair firstObject];
    assert(ID.name.length > 0);
    
    // get address
    NSString *addr = [pair lastObject];
    assert(addr.length >= 15);
    ID.address = [[MKMAddress alloc] initWithString:addr];
    assert(ID.address.isValid);
    
    // isValid
    ID.valid = (ID.name.length > 0 && ID.address.isValid);
}

@implementation MKMID

+ (instancetype)IDWithID:(id)ID {
    if ([ID isKindOfClass:[MKMID class]]) {
        return ID;
    } else if ([ID isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithString:ID];
    } else {
        NSAssert(!ID, @"unexpected ID: %@", ID);
        return nil;
    }
}

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        // lazy
        _name = nil;
        _address = nil;
        _terminal = nil;
        _valid = NO;
    }
    return self;
}

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr {
    NSString *res = nil;
    self = [self initWithName:seed address:addr terminal:res];
    return self;
}

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr
                    terminal:(const NSString *)res {
    NSString *string;
    if (res) {
        string = [NSString stringWithFormat:@"%@@%@/%@", seed, addr, res];
    } else {
        string = [NSString stringWithFormat:@"%@@%@", seed, addr];
    }
    
    if (self = [super initWithString:string]) {
        _name = [seed copy];
        _address = [addr copy];
        _terminal = [res copy];
        _valid = (seed.length > 0 && addr.isValid);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMID *ID = [super copyWithZone:zone];
    if (ID) {
        ID.name = _name;
        ID.address = _address;
        ID.terminal = _terminal;
        ID.valid = _valid;
    }
    return ID;
}

- (BOOL)isEqual:(id)object {
    MKMID *ID = [MKMID IDWithID:object];
    if (!self.isValid || !ID.isValid) {
        return NO;
    }
    // name
    if (![self.name isEqualToString:ID.name]) {
        return NO;
    }
    // address
    if (![self.address isEqual:ID.address]) {
        return NO;
    }
    return YES;
}

- (NSString *)name {
    if (!_name) {
        parse_id_string(_storeString, self);
    }
    return _name;
}

- (MKMAddress *)address {
    if (!_address) {
        parse_id_string(_storeString, self);
    }
    return _address;
}

- (NSString *)terminal {
    if (!_name || !_address) {
        parse_id_string(_storeString, self);
    }
    return _terminal;
}

- (BOOL)isValid {
    if (!_name || !_address) {
        parse_id_string(_storeString, self);
    }
    return _valid;
}

- (MKMNetworkType)type {
    return _address.network;
}

- (UInt32)number {
    return _address.code;
}

- (instancetype)naked {
    if (self.terminal) {
        return [[[self class] alloc] initWithName:self.name
                                          address:self.address];
    } else {
        return self;
    }
}

@end
