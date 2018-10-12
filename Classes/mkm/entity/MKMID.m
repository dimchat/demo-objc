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

#import "MKMEntityManager.h"

#import "MKMID.h"

@interface MKMID ()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) MKMAddress *address;

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
        NSArray *pair = [aString componentsSeparatedByString:@"@"];
        NSAssert([pair count] == 2, @"ID format error: %@", aString);
        
        // get name
        NSString *name = [pair firstObject];
        NSAssert([name length] > 0, @"ID.name error");
        
        // get address
        NSString *addr = [pair lastObject];
        NSAssert([addr length] >= 15, @"ID.address error");
        MKMAddress *address = [[MKMAddress alloc] initWithString:addr];
        NSAssert(address.isValid, @"address error");
        
        if (name.length > 0 && address.isValid) {
            self.name = name;
            self.address = address;
            _valid = YES;
        } else {
            _name = nil;
            _address = nil;
            _valid = NO;
        }
    }
    return self;
}

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr {
    NSString *string = [NSString stringWithFormat:@"%@@%@", seed, addr];
    
    if (self = [super initWithString:string]) {
        addr = [MKMAddress addressWithAddress:addr];
        if (seed.length > 0 && addr.isValid) {
            _name = [seed copy];
            _address = [addr copy];
            _valid = YES;
        } else {
            _name = nil;
            _address = nil;
            _valid = NO;
        }
    }
    return self;
}

- (id)copy {
    return [[MKMID alloc] initWithName:_name address:_address];
}

- (BOOL)isEqual:(id)object {
    if (_valid) {
        return [_storeString isEqualToString:object];
    } else {
        return NO;
    }
}

@end
