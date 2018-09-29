//
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

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
            // FIXME: above is just for test, please implement it
        } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
            // TODO: RSA encrypt
            _publicKey = [[MKMPublicKey alloc] initWithDictionary:self];
            // FIXME: above is just for test, please implement it
        }
    }
    return _publicKey;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC encrypt
        plaintext = [[ciphertext UTF8String] base58Decode];
        // FIXME: above is just for test, please implement it
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA encrypt
        plaintext = [[ciphertext UTF8String] base64Decode];
        // FIXME: above is just for test, please implement it
    }
    return plaintext;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC encrypt
        ciphertext = [[plaintext base58Encode] data];
        // FIXME: above is just for test, please implement it
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA encrypt
        ciphertext = [[plaintext base64Encode] data];
        // FIXME: above is just for test, please implement it
    }
    return ciphertext;
}

@end
