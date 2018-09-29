//
//  MKMPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPrivateKey.h"

#import "MKMPublicKey.h"

@implementation MKMPublicKey

- (NSData *)encrypt:(const NSData *)plaintext {
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

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC verify
        NSData *temp = [[ciphertext UTF8String] base58Decode];
        match = [plaintext isEqualToData:temp];
        // FIXME: above is just for test, please implement it
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA verify
        NSData *temp = [[ciphertext UTF8String] base64Decode];
        match = [plaintext isEqualToData:temp];
        // FIXME: above is just for test, please implement it
    }
    return match;
}

- (BOOL)isMatch:(const MKMPrivateKey *)SK {
    return [SK.publicKey isEqual:self];
}

@end
