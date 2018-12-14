//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

@interface MKMAESKey ()

@property (strong, nonatomic) NSData *data;

@property (nonatomic) NSUInteger keySize;
//@property (strong, nonatomic) NSString *initializeVector;

@end

@implementation MKMAESKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:SCAlgorithmAES],
                 @"algorithm error: %@", keyInfo);
        
        // lazy
        _data = nil;
        
        _keySize = 0;
        //_initializeVector = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAESKey *key = [super copyWithZone:zone];
    if (key) {
        key.data = _data;
        key.keySize = _keySize;
        //key.initializeVector = _initializeVector;
    }
    return key;
}

- (NSData *)data {
    while (!_data) {
        NSString *PW;
        
        // data
        PW = [_storeDictionary objectForKey:@"data"];
        if (PW) {
            _data = [PW base64Decode];
            break;
        }
        
        // random password
        unsigned char buf[32];
        arc4random_buf(buf, sizeof(buf));
        _data = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
        
        PW = [_data base64Encode];
        [_storeDictionary setObject:PW forKey:@"data"];
        break;
    }
    return _data;
}

- (NSUInteger)keySize {
    while (_keySize == 0) {
        if (self.data) {
            _keySize = self.data.length;
            break;
        }
        
        NSNumber *size = [_storeDictionary objectForKey:@"keySize"];
        if (size) {
            _keySize = size.unsignedIntegerValue;
            break;
        }
        
        _keySize = kCCKeySizeAES256; // 32
        [_storeDictionary setObject:@(_keySize) forKey:@"keySize"];
        break;
    }
    return _keySize;
}

//- (NSString *)initializeVector {
//    if (!_initializeVector) {
//        NSString *iv = [_storeDictionary objectForKey:@"initializeVector"];
//        if (!iv) {
//            iv = [_storeDictionary objectForKey:@"initVector"];
//            if (!iv) {
//                iv = [_storeDictionary objectForKey:@"iv"];
//                //NSAssert(iv, @"iv error: %@", _storeDictionary);
//            }
//        }
//        _initializeVector = iv;
//    }
//    return _initializeVector;
//}

#pragma mark - Protocol

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    //NSAssert(!self.initializeVector, @"do not support init vector now");
    
    // AES encrypt algorithm
    if (self.keySize == kCCKeySizeAES256) {
        ciphertext = [plaintext AES256EncryptWithKey:self.data];
    }
    
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    //NSAssert(!self.initializeVector, @"do not support init vector now");
    
    // AES decrypt algorithm
    if (self.keySize == kCCKeySizeAES256) {
        plaintext = [ciphertext AES256DecryptWithKey:self.data];
    }
    
    return plaintext;
}

@end

@implementation MKMAESKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMAESKey *PW = nil;
    
    // TODO: load AES key from persistent store
    // ...
    NSAssert(false, @"implement me");
    
    // key not found
    return PW;
}

@end
