//
//  MKMAddress.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMAddress.h"

@interface MKMAddress ()

@property (nonatomic) MKMNetworkType network;
@property (nonatomic) UInt32 code;

@property (nonatomic, getter=isValid) BOOL valid;

@end

/**
 Get check code of the address

 @param data - network + hash(CT)
 @return prefix 4 bytes after sha256*2
 */
static NSData * check_code(const NSData *data) {
    assert([data length] == 21);
    data = [data sha256d];
    assert([data length] == 32);
    return [data subdataWithRange:NSMakeRange(0, 4)];
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
 Parse string with BTC address format

 @param string - BTC address format string
 @param address - MKM address
 */
static void parse_address(const NSString *string, MKMAddress *address) {
    NSData *data = [string base58Decode];
    NSUInteger len = [data length];
    if (len == 25) {
        // Network ID
        const char *bytes = [data bytes];
        address.network = bytes[0];
        
        // Check Code
        NSData *prefix = [data subdataWithRange:NSMakeRange(0, len-4)];
        NSData *suffix = [data subdataWithRange:NSMakeRange(len-4, 4)];
        NSData *cc = check_code(prefix);
        address.code = user_number(cc);
        
        // isValid
        address.valid = [cc isEqualToData:suffix];
    } else {
        // other version ?
        assert(false);
    }
}

@implementation MKMAddress

+ (instancetype)addressWithAddress:(id)addr {
    if ([addr isKindOfClass:[MKMAddress class]]) {
        return addr;
    } else if ([addr isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithString:addr];
    } else {
        NSAssert(!addr, @"unexpected address: %@", addr);
        return nil;
    }
}

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        // lazy
        _network = MKMNetwork_Unknown;
        _code = 0;
        _valid = NO;
    }
    return self;
}

- (instancetype)initWithFingerprint:(const NSData *)CT
                            network:(MKMNetworkType)type
                            version:(NSUInteger)metaVersion {
    NSAssert(metaVersion == MKMAddressDefaultVersion, @"version error");
    NSString *string = nil;
    UInt32 code = 0;
    BOOL valid = NO;
    if (metaVersion == 0x01) {
        /**
         *  BTC address algorithm:
         *      hash = ripemd160(sha256(CT))
         *      code = sha256(sha256(network + hash)).prefix(4)
         *      addr = base58(network + hash + code)
         */
        
        // 1. hash = ripemd160(sha256(CT))
        NSData *hash = [[CT sha256] ripemd160];
        // 2. _h = network + hash
        NSMutableData *data;
        data = [[NSMutableData alloc] initWithBytes:&type length:1];
        [data appendData:hash];
        // 3. cc = sha256(sha256(_h)).prefix(4)
        NSData *cc = check_code(data);
        code = user_number(cc);
        // 4. addr = base58(_h + cc)
        [data appendData:cc];
        string = [data base58Encode];
        
        valid = YES;
    }
    
    if (self = [super initWithString:string]) {
        _network = type;
        _code = code;
        _valid = valid;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAddress *addr = [super copyWithZone:zone];
    if (addr) {
        addr.network = _network;
        addr.code = _code;
        addr.valid = _valid;
    }
    return addr;
}

- (BOOL)isEqual:(id)object {
    NSAssert([object isKindOfClass:[NSString class]], @"error");
    return [_storeString isEqualToString:object];
}

- (MKMNetworkType)network {
    if (_network == MKMNetwork_Unknown) {
        parse_address(_storeString, self);
    }
    return _network;
}

- (UInt32)code {
    if (_network == MKMNetwork_Unknown) {
        parse_address(_storeString, self);
    }
    return _code;
}

- (BOOL)isValid {
    if (_network == MKMNetwork_Unknown) {
        parse_address(_storeString, self);
    }
    return _valid;
}

@end
