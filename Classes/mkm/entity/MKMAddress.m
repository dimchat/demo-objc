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
 Get check code

 @param input - ciphertext
 @return prefix 4 bytes after sha256*2
 */
static NSData * check_code(const NSData *input) {
    assert([input length] == 21);
    NSData *data = [[input sha256] sha256];
    assert([data length] == 32);
    return [data subdataWithRange:NSMakeRange(0, 4)];
}

/**
 User number

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
static NSString *build_address(const NSData * CT, MKMNetworkType network, NSUInteger version) {
    assert(version == MKMAddressDefaultVersion);
    NSString *addr = nil;
    switch (version) {
        case 0x01: {
            // 1. hash = ripemd160(sha256(CT))
            NSData *hash = [[CT sha256] ripemd160];
            // 2. str = 0x00 + hash
            NSMutableData *str = [NSMutableData dataWithBytes:&network length:1];
            [str appendData:hash];
            // 3. cc = sha256(sha256(str)).prefix(4)
            NSData *cc = check_code(str);
            // 4. addr = base58(str + cc)
            [str appendData:cc];
            addr = [str base58Encode];
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

@property (nonatomic) MKMNetworkType network;
@property (nonatomic) UInt32 number;

@property (nonatomic) BOOL isValid;

@end

@implementation MKMAddress

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        _isValid = [self analyse];
    }
    return self;
}

- (instancetype)initWithFingerprint:(const NSData *)CT
                            network:(MKMNetworkType)type
                            version:(NSUInteger)metaVersion {
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
    NSAssert(len == 25, @"address length error");
    if (len < 25) {
        // address length should be 25 bytes
        return NO;
    }
    
    NSData *prefix = [addr subdataWithRange:NSMakeRange(0, len-4)];
    NSData *suffix = [addr subdataWithRange:NSMakeRange(len-4, 4)];
    
    NSData *cc = check_code(prefix);
    if (![cc isEqualToData:suffix]) {
        // check code error
        return NO;
    }
    
    const char *bytes = [addr bytes];
    if (bytes[0] != MKMNetwork_Main &&
        bytes[0] != MKMNetwork_Group &&
        bytes[0] != MKMNetwork_Moments) {
        // network id error
        return NO;
    }
    _network = bytes[0];
    
    _number = user_number(cc);
    return YES;
}

@end
