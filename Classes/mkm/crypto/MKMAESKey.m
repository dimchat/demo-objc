//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Crypto.h"

#import "MKMAESKey.h"

@interface MKMAESKey ()

@property (nonatomic) NSUInteger keySizeInBits;
@property (strong, nonatomic) NSString *initializeVector;

@end

@implementation MKMAESKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:SCAlgorithmAES],
                 @"algorithm error: %@", keyInfo);
        
        // lazy
        _keySizeInBits = 0;
        _initializeVector = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAESKey *key = [super copyWithZone:zone];
    if (key) {
        key.keySizeInBits = _keySizeInBits;
        key.initializeVector = _initializeVector;
    }
    return key;
}

- (NSUInteger)keySizeInBits {
    if (_keySizeInBits == 0) {
        NSNumber *keySize = [_storeDictionary objectForKey:@"keySize"];
        if (!keySize) {
            keySize = [_storeDictionary objectForKey:@"size"];
        }
        if (keySize) {
            _keySizeInBits = [keySize unsignedIntegerValue];
        } else {
            _keySizeInBits = kCCKeySizeAES256; // 32
            [_storeDictionary setObject:@(_keySizeInBits) forKey:@"keySize"];
        }
    }
    return _keySizeInBits;
}

- (NSString *)initializeVector {
    if (!_initializeVector) {
        NSString *iv = [_storeDictionary objectForKey:@"initializeVector"];
        if (!iv) {
            iv = [_storeDictionary objectForKey:@"initVector"];
            if (!iv) {
                iv = [_storeDictionary objectForKey:@"iv"];
                //NSAssert(iv, @"iv error: %@", _storeDictionary);
            }
        }
        _initializeVector = iv;
    }
    return _initializeVector;
}

#pragma mark - Protocol

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    NSAssert(self.keySizeInBits == kCCKeySizeAES256, @"only support AES-256 now");
    NSAssert(!self.initializeVector, @"do not support init vector now");
    
    // AES encrypt algorithm
    if (self.keySizeInBits == kCCKeySizeAES256) {
        ciphertext = [plaintext AES256EncryptWithKey:self.passphrase];
    }
    
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    NSAssert(self.keySizeInBits == kCCKeySizeAES256, @"only support AES-256 now");
    NSAssert(!self.initializeVector, @"do not support init vector now");
    
    // AES decrypt algorithm
    if (self.keySizeInBits == kCCKeySizeAES256) {
        plaintext = [ciphertext AES256DecryptWithKey:self.passphrase];
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
