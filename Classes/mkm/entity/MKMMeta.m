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

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithMetaInfo:dict];
    return self;
}

- (instancetype)initWithMetaInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    
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
        self = [self initWithDictionary:dict];
    } else {
        self = [self init];
    }
    if (self) {
        self.version = ver;
        self.seed = seed;
        self.key = PK;
        self.fingerprint = CT;
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
        self = [self initWithDictionary:mDict];
    } else {
        self = [self init];
    }
    if (self) {
        self.version = ver;
        self.seed = name;
        self.key = PK;
        self.fingerprint = CT;
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
    // 1. check "address <=> CT"
    //    address == btc_hash(network, CT)
    MKMAddress *addr;
    addr = [[MKMAddress alloc] initWithFingerprint:_fingerprint
                                           network:address.network
                                           version:_version];
    if (![address isEqualToString:addr]) {
        return NO;
    }
    
    // 2. check "seed <=> CT & PK"
    //    verify(seed, CT, PK)
    return [_key verify:[_seed data] signature:_fingerprint];
}

@end
