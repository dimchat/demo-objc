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

@property (strong, nonatomic) MKMPublicKey *publicKey;

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
        _name = [seed copy];
        _address = [addr copy];
    }
    return self;
}

- (id)copy {
    return [[MKMID alloc] initWithName:_name address:_address];
}

- (BOOL)isValid {
    return _address.isValid && _name.length > 0;
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey) {
        MKMEntityManager *em = [MKMEntityManager sharedManager];
        MKMMeta *meta = [em metaWithID:self];
        if ([self checkMeta:meta]) {
            //_publicKey = [meta key];
        }
    }
    return _publicKey;
}

- (BOOL)isEqual:(id)object {
    if (![self isValid]) {
        return NO;
    }
    return [_storeString isEqualToString:object];
}

- (BOOL)checkMeta:(const MKMMeta *)meta {
    BOOL correct = [meta match:self];
    if (correct && _address.network == MKMNetwork_Main) {
        self.publicKey = meta.key;
    }
    return correct;
}

@end
