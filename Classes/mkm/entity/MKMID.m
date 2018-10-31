//
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMID.h"

@interface MKMID ()

@property (strong, nonatomic, nonnull) NSString *name;
@property (strong, nonatomic, nonnull) MKMAddress *address;

@property (strong, nonatomic, nullable) NSString *terminal;

@property (nonatomic, getter=isValid) BOOL valid;

@end

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
        // get terminal
        NSString *terminal = nil;
        NSArray *pair = [aString componentsSeparatedByString:@"/"];
        if (pair.count == 2) {
            aString = pair.firstObject; // drop the tail
            terminal = pair.lastObject;
        }
        
        pair = [aString componentsSeparatedByString:@"@"];
        NSAssert(pair.count == 2, @"ID format error: %@", aString);
        
        // get name
        NSString *name = [pair firstObject];
        NSAssert(name.length > 0, @"ID.name error");
        
        // get address
        NSString *addr = [pair lastObject];
        NSAssert(addr.length >= 15, @"ID.address error");
        MKMAddress *address = [[MKMAddress alloc] initWithString:addr];
        NSAssert(address.isValid, @"address error");
        
        if (name.length > 0 && address.isValid) {
            _name = [name copy];
            _address = address;
            _terminal = [terminal copy];
            _valid = YES;
        } else {
            _name = nil;
            _address = nil;
            _terminal = nil;
            _valid = NO;
        }
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
        addr = [MKMAddress addressWithAddress:addr];
        if (seed.length > 0 && addr.isValid) {
            _name = [seed copy];
            _address = [addr copy];
            _terminal = [res copy];
            _valid = YES;
        } else {
            _name = nil;
            _address = nil;
            _terminal = nil;
            _valid = NO;
        }
    }
    return self;
}

- (NSUInteger)number {
    return _address.code;
}

- (id)copy {
    return [[[self class] alloc] initWithName:_name
                                      address:_address
                                     terminal:_terminal];
}

- (BOOL)isEqual:(id)object {
    if (!_valid) {
        return NO;
    }
    MKMID *ID = [MKMID IDWithID:object];
    if (!ID.isValid) {
        return NO;
    }
    // name
    if (![ID.name isEqualToString:_name]) {
        return NO;
    }
    // address
    if (![ID.address isEqual:_address]) {
        return NO;
    }
    return YES;
}

- (instancetype)naked {
    if (_terminal) {
        return [[[self class] alloc] initWithName:_name
                                          address:_address];
    } else {
        return self;
    }
}

@end
