//
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMKeyStore.h"

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMMeta.h"

@interface MKMMeta ()

@property (nonatomic) NSUInteger version;

@property (strong, nonatomic) const NSString *seed;
@property (strong, nonatomic) const MKMPublicKey *key;
@property (strong, nonatomic) const NSData *fingerprint;

@end

@implementation MKMMeta

+ (instancetype)metaWithMeta:(id)meta {
    if ([meta isKindOfClass:[MKMMeta class]]) {
        return meta;
    } else if ([meta isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:meta];
    } else if ([meta isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:meta];
    } else {
        NSAssert(!meta, @"unexpected meta: %@", meta);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSNumber *version = [dict objectForKey:@"version"];
    id publicKey = [dict objectForKey:@"publicKey"];
    NSString *fingerprint = [dict objectForKey:@"fingerprint"];
    const NSString *seed = [dict objectForKey:@"seed"];
    
    const MKMPublicKey *PK = nil;
    if ([publicKey isKindOfClass:[NSString class]]) {
        PK = [[MKMPublicKey alloc] initWithJSONString:publicKey];
    } else if ([publicKey isKindOfClass:[NSDictionary class]]) {
        NSString *algor = [publicKey objectForKey:@"algorithm"];
        PK = [[MKMPublicKey alloc] initWithAlgorithm:algor keyInfo:publicKey];
    }
    const NSData *CT = [fingerprint base64Decode];
    NSUInteger ver = version.unsignedIntegerValue;
    NSAssert(ver == MKMAddressDefaultVersion, @"unknown version: %lu", ver);
    
    BOOL correct = [PK verify:[seed data] signature:CT];
    NSAssert(correct, @"fingerprint error");
    if (correct) {
        self = [super initWithDictionary:dict];
        if (self) {
            self.version = ver;
            self.seed = seed;
            self.key = PK;
            self.fingerprint = CT;
        }
    } else {
        self = [self init];
    }
    
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(const NSData *)CT
                     version:(NSUInteger)ver {
    NSAssert(ver == MKMAddressDefaultVersion, @"unknown version: %lu", ver);
    
    BOOL correct = [PK verify:[name data] signature:CT];
    NSAssert(correct, @"fingerprint error");
    if (correct) {
        NSNumber *version = [NSNumber numberWithUnsignedInteger:ver];
        NSString *fingerprint = [CT base64Encode];
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [mDict setObject:version forKey:@"version"];
        [mDict setObject:name forKey:@"seed"];
        [mDict setObject:PK forKey:@"publicKey"];
        [mDict setObject:fingerprint forKey:@"fingerprint"];
        
        self = [super initWithDictionary:mDict];
        if (self) {
            self.version = ver;
            self.seed = name;
            self.key = PK;
            self.fingerprint = CT;
        }
    } else {
        self = [self init];
    }
    
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                  privateKey:(const MKMPrivateKey *)SK {
    
    NSAssert([PK isMatch:SK], @"PK must match SK");
    NSData *CT = [SK sign:[name data]];
    self = [self initWithSeed:name
                    publicKey:PK
                  fingerprint:CT
                      version:MKMAddressDefaultVersion];
    
    return self;
}

- (id)copy {
    return [[MKMMeta alloc] initWithSeed:_seed publicKey:_key fingerprint:_fingerprint version:_version];
}

- (BOOL)match:(const MKMID *)ID {
    NSString *name = [_seed copy];
    return [ID.name isEqualToString:name] && [self matchAddress:ID.address];
}

- (BOOL)matchAddress:(const MKMAddress *)address {
    // 1. check "address <=> CT":
    //    address == btc_address(network, CT)
    MKMAddress *addr;
    addr = [[MKMAddress alloc] initWithFingerprint:_fingerprint
                                           network:address.network
                                           version:_version];
    if (![address isEqualToString:addr]) {
        return NO;
    }
    
    // 2. check "seed <=> CT & PK":
    //    verify(seed, CT, PK)
    return [_key verify:[_seed data] signature:_fingerprint];
}

@end
