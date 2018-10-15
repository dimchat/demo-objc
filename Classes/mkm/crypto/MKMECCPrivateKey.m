//
//  MKMECCPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "ecc.h"

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMECCPublicKey.h"

#import "MKMECCPrivateKey.h"

@interface MKMECCPrivateKey () {
    
    NSString *_curve;
    
    NSData *_privateData;
    NSData *_publicData;
    
    MKMECCPublicKey *_publicKey;
}

@end

@implementation MKMECCPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([_algorithm isEqualToString:ACAlgorithmECC], @"algorithm error");
        //keyInfo = _storeDictionary;
        
        // ECC curve
        NSString *curve = [keyInfo objectForKey:@"curve"];
        if (curve) {
            _curve = curve;
        } else {
            _curve = @"secp256r1";
        }
        NSAssert([_curve isEqualToString:@"secp256r1"], @"only secp256r1 now");
        
        // ECC key data
        uint8_t p_publicKey[ECC_BYTES + 1];
        uint8_t p_privateKey[ECC_BYTES];
        
        NSString *data = [keyInfo objectForKey:@"data"];
        if (data) {
            // private key data
            _privateData = [data base64Decode];
            NSAssert(_privateData.length == ECC_BYTES, @"data error");
            
            // get public key data from private key
            [_privateData getBytes:p_privateKey length:ECC_BYTES];
            int res = ecc_copy_public_key(p_publicKey, p_privateKey);
            if (res == 1) {
                _publicData = [[NSData alloc] initWithBytes:p_publicKey
                                                     length:(ECC_BYTES + 1)];
            }
        } else {
            // Generate key pairs
            int res = ecc_make_key(p_publicKey, p_privateKey);
            NSAssert(res == 1, @"failed to generate keys");
            
            if (res == 1) {
                // private key data
                _privateData = [[NSData alloc] initWithBytes:p_privateKey
                                                      length:ECC_BYTES];
                // set values in dictionary
                NSString *privateContent = [_privateData base64Encode];
                [_storeDictionary setObject:privateContent forKey:@"data"];
                [_storeDictionary setObject:_curve forKey:@"curve"];
                
                // public key data
                _publicData = [[NSData alloc] initWithBytes:p_publicKey
                                                     length:(ECC_BYTES + 1)];
            }
        }
    }
    return self;
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey && _publicData) {
        NSString *publicContent = [_publicData base64Encode];
        // create public key
        NSDictionary *keyInfo = @{@"algorithm":_algorithm,
                                  @"curve"    :_curve,
                                  @"data"     :publicContent,
                                  };
        _publicKey = [[MKMECCPublicKey alloc] initWithDictionary:keyInfo];
    }
    return _publicKey;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // TODO: ECC encrypt
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    if (_privateData.length == ECC_BYTES && plaintext.length <= ECC_BYTES) {
        uint8_t p_privateKey[ECC_BYTES];
        uint8_t p_hash[ECC_BYTES];
        uint8_t p_signature[ECC_BYTES * 2];
        
        [_privateData getBytes:p_privateKey length:_privateData.length];
        [plaintext getBytes:p_hash length:plaintext.length];
        int res = ecdsa_sign(p_privateKey, p_hash, p_signature);
        if (res == 1) {
            ciphertext = [[NSData alloc] initWithBytes:p_signature
                                                length:(ECC_BYTES * 2)];
        }
    }
    
    return ciphertext;
}

@end

@implementation MKMECCPrivateKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMECCPrivateKey *SK = nil;
    
    // TODO: load ECC private key from persistent store
    
    // key not found
    return SK;
}

@end
