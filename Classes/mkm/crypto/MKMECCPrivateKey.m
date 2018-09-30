//
//  MKMECCPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMECCPrivateKey.h"

@implementation MKMECCPrivateKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmECC], @"algorithm error");
    if (self = [super initWithDictionary:info]) {
        // TODO: ECC algorithm arguments
    }
    return self;
}

- (const MKMPublicKey *)publicKey {
    MKMPublicKey *PK = nil;
    
    // TODO: ECC encrypt
    PK = [[MKMPublicKey alloc] initWithAlgorithm:_algorithm keyInfo:_acKeyInfo];
    // FIXME: above is just for test, please implement it
    
    return PK;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // TODO: ECC encrypt
    plaintext = [[ciphertext UTF8String] base58Decode];
    // FIXME: above is just for test, please implement it
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: ECC encrypt
    ciphertext = [[plaintext base58Encode] data];
    // FIXME: above is just for test, please implement it
    
    return ciphertext;
}

@end
