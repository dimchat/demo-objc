//
//  MKMECCPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMECCPublicKey.h"

#import "MKMECCPrivateKey.h"

@interface MKMECCPrivateKey () {
    
    MKMPublicKey *_publicKey;
}

@property (strong, nonatomic) NSString *curve;

@end

@implementation MKMECCPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmECC], @"algorithm error");
        
        // TODO: ECC variables
        _curve = nil;
        _publicKey = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMECCPrivateKey *key = [super copyWithZone:zone];
    if (key) {
        key.curve = _curve;
    }
    return key;
}

- (NSString *)curve {
    if (!_curve) {
        _curve = [_storeDictionary objectForKey:@"curve"];
        NSAssert(_curve, @"curve error: %@", _storeDictionary);
    }
    return _curve;
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey) {
        // TODO: create public key from private key
        // ...
    }
    return _publicKey;
}

#pragma mark - Protocol

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // TODO: ECC encrypt
    // ...
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)data {
    NSData *signature = nil;
    
    // TODO: ECC sign
    
    return signature;
}

@end

@implementation MKMECCPrivateKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMECCPrivateKey *SK = nil;
    
    // TODO: load ECC private key from persistent store
    // ...
    
    return SK;
}

@end
