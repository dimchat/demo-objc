//
//  MKMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMRSAPrivateKey.h"

@implementation MKMRSAPrivateKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmRSA], @"algorithm error");
    if (self = [super initWithDictionary:info]) {
        // TODO: RSA algorithm arguments
    }
    return self;
}

- (const MKMPublicKey *)publicKey {
    MKMPublicKey *PK = nil;
    
    // TODO: RSA encrypt
    PK = [[MKMPublicKey alloc] initWithAlgorithm:_algorithm keyInfo:_acKeyInfo];
    // FIXME: above is just for test, please implement it
    
    return PK;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // TODO: RSA encrypt
    plaintext = [[ciphertext UTF8String] base64Decode];
    // FIXME: above is just for test, please implement it
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: RSA encrypt
    ciphertext = [[plaintext base64Encode] data];
    // FIXME: above is just for test, please implement it
    
    return ciphertext;
}

@end
