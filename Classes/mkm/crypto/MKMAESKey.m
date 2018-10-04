//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

@interface MKMAESKey () {
    
    NSUInteger _keySize;
}

@end

@implementation MKMAESKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:SCAlgorithmAES], @"algorithm error");
    
    if (self = [super initWithDictionary:info]) {
        // AES algorithm arguments
        NSNumber *keySize = [info objectForKey:@"keySize"];
        if (!keySize) {
            keySize = [info objectForKey:@"size"];
        }
        if (keySize) {
            _keySize = [keySize unsignedIntegerValue];
        } else {
            _keySize = kCCKeySizeAES256; // 32
        }
    }
    
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    NSAssert(_keySize == kCCKeySizeAES256, @"only support AES-256 now");
    
    // AES encrypt algorithm
    if (_keySize == kCCKeySizeAES256) {
        ciphertext = [plaintext AES256EncryptWithKey:_passphrase];
    }
    
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    NSAssert(_keySize == kCCKeySizeAES256, @"only support AES-256 now");
    
    // AES decrypt algorithm
    if (_keySize == kCCKeySizeAES256) {
        plaintext = [ciphertext AES256DecryptWithKey:_passphrase];
    }
    
    return plaintext;
}

@end
