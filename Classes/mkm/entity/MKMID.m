//
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMID.h"

@interface MKMID ()

@property (strong, nonatomic) const NSString *name;
@property (strong, nonatomic) const MKMAddress *address;

@property (strong, nonatomic) const MKMPublicKey *publicKey;

@end

@implementation MKMID

- (instancetype)initWithString:(NSString *)aString {
    NSArray *pair = [_storeString componentsSeparatedByString:@"@"];
    NSAssert([pair count] == 2, @"ID format error: %@", aString);
    
    // get name
    NSString *name = [pair firstObject];
    NSAssert([name length] > 0, @"ID.name error");
    
    // get address
    NSString *addr = [pair lastObject];
    NSAssert([addr length] >= 15, @"ID.address error");
    MKMAddress *address = [[MKMAddress alloc] initWithString:addr];
    NSAssert(address.isValid, @"address error");
    
    if (self = [super initWithString:aString]) {
        self.name = name;
        self.address = address;
    }
    return self;
}

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr {
    NSString *string = [NSString stringWithFormat:@"%@@%@", seed, addr];
    if (self = [super initWithString:string]) {
        self.name = seed;
        self.address = addr;
    }
    return self;
}

- (id)copy {
    return [[MKMID alloc] initWithName:_name address:_address];
}

- (NSUInteger)number {
    return _address.number;
}

- (BOOL)isValid {
    return _address.isValid && _name.length > 0;
}

- (BOOL)checkMeta:(const MKMMeta *)meta {
    BOOL correct = [meta match:self];
    if (correct) {
        self.publicKey = meta.publicKey;
    }
    return correct;
}

@end
