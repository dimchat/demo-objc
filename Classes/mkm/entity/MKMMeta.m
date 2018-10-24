//
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMMeta.h"

@interface MKMMeta ()

@property (nonatomic) NSUInteger version;

@property (strong, nonatomic) NSString *seed;
@property (strong, nonatomic) MKMPublicKey *key;
@property (strong, nonatomic) NSData *fingerprint;

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
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // get meta data
        NSNumber *version = [dict objectForKey:@"version"];
        NSString *seed = [dict objectForKey:@"seed"];
        NSString *fingerprint = [dict objectForKey:@"fingerprint"];
        id publicKey = [dict objectForKey:@"key"];
        
        MKMPublicKey *PK = [MKMPublicKey keyWithKey:publicKey];
        NSData *CT = [fingerprint base64Decode];
        NSData *data = [seed data];
        NSUInteger ver = version.unsignedIntegerValue;
        NSAssert(ver == MKMAddressDefaultVersion, @"unknown version");
        
        // check seed & fingerprint with (public) key
        BOOL correct = [PK verify:data withSignature:CT];
        NSAssert(correct, @"fingerprint error");
        
        if (correct) {
            _version = ver;
            _seed = seed;
            _key = PK;
            _fingerprint = CT;
        } else {
            _version = 0;
            _seed = nil;
            _key = nil;
            _fingerprint = nil;
        }
    }
    
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(const NSData *)CT
                     version:(NSUInteger)ver {
    NSAssert(ver == MKMAddressDefaultVersion, @"unknown version: %lu", ver);
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    BOOL correct = [PK verify:[name data] withSignature:CT];
    NSAssert(correct, @"fingerprint error");
    
    if (correct) {
        [mDict setObject:@(ver) forKey:@"version"];
        [mDict setObject:name forKey:@"seed"];
        [mDict setObject:PK forKey:@"key"];
        [mDict setObject:[CT base64Encode] forKey:@"fingerprint"];
    }
    
    if (self = [super initWithDictionary:mDict]) {
        if (correct) {
            _version = ver;
            _seed = [name copy];
            _key = [PK copy];
            _fingerprint = [CT copy];
        } else {
            _version = 0;
            _seed = nil;
            _key = nil;
            _fingerprint = nil;
        }
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
    return [[[self class] alloc] initWithSeed:_seed
                                    publicKey:_key
                                  fingerprint:_fingerprint
                                      version:_version];
}

#pragma mark - ID & address

- (BOOL)matchID:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    return [_seed isEqualToString:ID.name] && [self matchAddress:ID.address];
}

// check: address == btc_address(network, CT)
- (BOOL)matchAddress:(const MKMAddress *)address {
    NSAssert(address.isValid, @"Invalid address");
    MKMAddress *addr = [self buildAddressWithNetworkID:address.network];
    return [address isEqualToString:addr];
}

- (MKMID *)buildIDWithNetworkID:(MKMNetworkType)type {
    MKMAddress *addr = [self buildAddressWithNetworkID:type];
    return [[MKMID alloc] initWithName:_seed address:addr];
}

- (MKMAddress *)buildAddressWithNetworkID:(MKMNetworkType)type {
    return [[MKMAddress alloc] initWithFingerprint:_fingerprint
                                           network:type
                                           version:_version];
}

@end
