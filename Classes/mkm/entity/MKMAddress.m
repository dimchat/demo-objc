//
//  MKMAddress.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMMeta.h"

#import "MKMAddress.h"

/**
 Get hash of the fingerprint

 @param fingerprint - ciphertext
 @return hash of CT
 */
static NSData *btc_hash(const NSData *fingerprint) {
    return [[fingerprint sha256] ripemd160];
}

/**
 Get check code of the address

 @param network_hash - ciphertext
 @return prefix 4 bytes after sha256*2
 */
static NSData * btc_checkcode(const NSData *network_hash) {
    assert([network_hash length] == 21);
    NSData *data = [[network_hash sha256] sha256];
    assert([data length] == 32);
    return [data subdataWithRange:NSMakeRange(0, 4)];
}

/**
 Get address like BitCoin

 @param CT - fingerprint
 @param network - Network ID
 @return address
 */
static NSString *btc_address(const NSData * CT, MKMNetworkID network) {
    // 1. hash = ripemd160(sha256(CT))
    NSData *hash = btc_hash(CT);
    // 2. str = 0x00 + hash
    NSMutableData *str = [NSMutableData dataWithBytes:&network length:1];
    [str appendData:hash];
    // 3. cc = sha256(sha256(str)).prefix(4)
    NSData *cc = btc_checkcode(str);
    // 4. addr = base58(str + cc)
    [str appendData:cc];
    return [str base58Encode];
}

/**
 Get user number, which for remembering and searching user

 @param cc - check code
 @return unsigned integer
 */
static UInt32 user_number(const NSData *cc) {
    assert([cc length] == 4);
    UInt32 number;
    memcpy(&number, [cc bytes], 4);
    return number;
}

/**
 ID address
 
 @param CT - fingerprint
 @return address
 */
static NSString *build_address(const NSData * CT, MKMNetworkID network, NSUInteger version) {
    assert(version == MKMAddressDefaultVersion);
    NSString *addr = nil;
    switch (version) {
        case 0x01: {
            addr = btc_address(CT, network);
        }
            break;
            
        case 0x02: {
            // TODO: Ethereum address algorithm
        }
            break;
            
        default:
            break;
    }
    return addr;
}

@interface MKMAddress ()

@property (nonatomic) MKMNetworkID network;
@property (nonatomic) UInt32 code;

@property (nonatomic) BOOL isValid;

@end

@implementation MKMAddress

+ (instancetype)addressWithAddress:(id)addr {
    if ([addr isKindOfClass:[MKMAddress class]]) {
        return addr;
    } else if ([addr isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithString:addr];
    } else {
        NSAssert(!addr, @"unexpected address: %@", addr);
        return addr;
    }
}

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        _isValid = [self analyse];
    }
    return self;
}

- (instancetype)initWithFingerprint:(const NSData *)CT
                            network:(MKMNetworkID)type
                            version:(NSUInteger)metaVersion {
    NSAssert(metaVersion == MKMAddressDefaultVersion, @"version error");
    NSString *addr = build_address(CT, type, metaVersion);
    
    if (self = [self initWithString:addr]) {
        NSAssert(_network == type, @"error");
        NSAssert(_isValid, @"error");
    }
    return self;
}

- (id)copy {
    return [[MKMAddress alloc] initWithString:self];
}

- (BOOL)analyse {
    NSData *addr = [_storeString base58Decode];
    NSUInteger len = [addr length];
    NSAssert(len == 25, @"only support BTC address now");
    
    if (len == 25) {
        // address like BTC
        const char *bytes = [addr bytes];
        UInt8 network = bytes[0];
        if (network != MKMNetwork_Main &&
            network != MKMNetwork_Group &&
            network != MKMNetwork_Moments) {
            // network id error
            return NO;
        }
        
        NSData *prefix = [addr subdataWithRange:NSMakeRange(0, len-4)];
        NSData *suffix = [addr subdataWithRange:NSMakeRange(len-4, 4)];
        NSData *cc = btc_checkcode(prefix);
        if (![cc isEqualToData:suffix]) {
            // check code error
            return NO;
        }
        
        _network = network;
        _code = user_number(cc);
        
        return YES;
    }
    
    return NO;
}

@end
