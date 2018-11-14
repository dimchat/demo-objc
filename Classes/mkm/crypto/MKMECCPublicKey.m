//
//  MKMECCPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMECCPrivateKey.h"

#import "MKMECCPublicKey.h"

@interface MKMECCPublicKey ()

@property (strong, nonatomic) NSString *curve;

@end

@implementation MKMECCPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmECC], @"algorithm error");
        
        // TODO: ECC variables
        _curve = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMECCPublicKey *key = [super copyWithZone:zone];
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

#pragma mark - Protocol

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: ECC encrypt
    // ...
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
 withSignature:(const NSData *)ciphertext {
    BOOL match = NO;
    
    // TODO: ECC verify
    // ...
    
    return match;
}

@end

@implementation MKMECCPublicKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMECCPublicKey *PK = nil;
    
    // TODO: load ECC public key from persistent store
    // ...
    
    // finally, try by private key
    if (!PK) {
        MKMECCPrivateKey *SK;
        SK = [MKMECCPrivateKey loadKeyWithIdentifier:identifier];
        PK = (MKMECCPublicKey *)SK.publicKey;
    }
    
    return PK;
}

@end
