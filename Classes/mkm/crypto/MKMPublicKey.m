//
//  MKMPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"

#import "MKMPublicKey.h"

@implementation MKMPublicKey

- (NSData *)encrypt:(const NSData *)plaintext {
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

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    if ([_algorithm isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC verify
        match = YES;
    } else if ([_algorithm isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA verify
        match = YES;
    }
    return match;
}

- (BOOL)isMatch:(const MKMPrivateKey *)SK {
    return [SK.publicKey isEqual:self];
}

@end
