//
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMPrivateKey.h"

@interface MKMPrivateKey ()

@property (strong, nonatomic) const MKMPublicKey *publicKey;

@end

@implementation MKMPrivateKey

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK {
    if (self = [self initWithJSONString:json]) {
        NSAssert([PK isMatch:self], @"PK not match SK");
    }
    return self;
}

- (const MKMPublicKey *)publicKey {
    if (!_publicKey) {
        if ([_algorithm isEqualToString:ACAlgorithmECC]) {
            // TODO: ECC encrypt
            _publicKey = [[MKMPublicKey alloc] initWithDictionary:self];
        } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
            // TODO: RSA encrypt
            _publicKey = [[MKMPublicKey alloc] initWithDictionary:self];
        }
    }
    return _publicKey;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC encrypt
        ciphertext = plaintext;
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA encrypt
        ciphertext = plaintext;
    }
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC encrypt
        plaintext = ciphertext;
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA encrypt
        plaintext = ciphertext;
    }
    return plaintext;
}

@end
