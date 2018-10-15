//
//  MKMECCPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "ecc.h"

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMECCPrivateKey.h"

#import "MKMECCPublicKey.h"

@interface MKMECCPublicKey () {
    
    NSString *_curve;
    
    NSData *_publicData;
}

@end

@implementation MKMECCPublicKey

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
        NSString *data = [keyInfo objectForKey:@"data"];
        if (data) {
            _publicData = [data base64Decode];
            NSAssert(_publicData.length == (ECC_BYTES + 1), @"data error");
        }
    }
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: ECC encrypt
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    
    if (_publicData.length == (ECC_BYTES + 1) &&
        plaintext.length <= ECC_BYTES &&
        ciphertext.length == (ECC_BYTES * 2)) {
        uint8_t p_publicKey[ECC_BYTES + 1];
        uint8_t p_hash[ECC_BYTES];
        uint8_t p_signature[ECC_BYTES * 2];
        
        [_publicData getBytes:p_publicKey length:_publicData.length];
        [plaintext getBytes:p_hash length:plaintext.length];
        [ciphertext getBytes:p_signature length:ciphertext.length];
        int res = ecdsa_verify(p_publicKey, p_hash, p_signature);
        if (res == 1) {
            match = YES;
        }
    }
    
    return match;
}

@end

@implementation MKMECCPublicKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMECCPublicKey *PK = nil;
    
    // TODO: load ECC public key from persistent store
    
    // finally, try by private key
    MKMECCPrivateKey *SK = [MKMECCPrivateKey loadKeyWithIdentifier:identifier];
    PK = (MKMECCPublicKey *)SK.publicKey;
    
    return PK;
}

@end
