//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

@interface MKMAESKey () {
    
    NSUInteger _keySize;
    NSString * _initVector;
}

@end

@implementation MKMAESKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([_algorithm isEqualToString:SCAlgorithmAES], @"algorithm error");
        keyInfo = _storeDictionary;
        
        // key size
        NSNumber *keySize = [keyInfo objectForKey:@"keySize"];
        if (!keySize) {
            keySize = [keyInfo objectForKey:@"size"];
        }
        if (keySize) {
            _keySize = [keySize unsignedIntegerValue];
        } else {
            _keySize = kCCKeySizeAES256; // 32
            [_storeDictionary setObject:@(_keySize) forKey:@"keySize"];
        }
        
        // initialize vector
        NSString *initVector = [keyInfo objectForKey:@"initVector"];
        if (!initVector) {
            initVector = [keyInfo objectForKey:@"iv"];
        }
        _initVector = initVector;
    }
    
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    NSAssert(_keySize == kCCKeySizeAES256, @"only support AES-256 now");
    NSAssert(!_initVector, @"do not support init vector now");
    
    // AES encrypt algorithm
    if (_keySize == kCCKeySizeAES256) {
        ciphertext = [plaintext AES256EncryptWithKey:_passphrase];
    }
    
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    NSAssert(_keySize == kCCKeySizeAES256, @"only support AES-256 now");
    NSAssert(!_initVector, @"do not support init vector now");
    
    // AES decrypt algorithm
    if (_keySize == kCCKeySizeAES256) {
        plaintext = [ciphertext AES256DecryptWithKey:_passphrase];
    }
    
    return plaintext;
}

@end

@implementation MKMAESKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMAESKey *PW = nil;
    
    // TODO: load AES key from persistent store
    
    // key not found
    return PW;
}

@end
