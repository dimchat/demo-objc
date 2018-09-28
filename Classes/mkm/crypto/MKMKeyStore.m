//
//  MKMKeyStore.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMKeyStore.h"

@interface MKMKeyStore ()

@property (strong, nonatomic) const MKMPrivateKey *privateKey;
@property (strong, nonatomic) const MKMPublicKey *publicKey;

@end

@implementation MKMKeyStore

- (instancetype)init {
    self = [self initWithAlgorithm:ACAlgorithmECC];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)name {
    MKMPrivateKey *SK = nil;
    MKMPublicKey *PK = nil;
    if ([name isEqualToString:ACAlgorithmECC]) {
        // TODO: ECC keys generation
    } else if ([name isEqualToString:ACAlgorithmRSA]) {
        // TODO: RSA keys generation
    }
    self = [self initWithPublicKey:PK privateKey:SK];
    return self;
}

/* designated initializer */
- (instancetype)initWithPublicKey:(const MKMPublicKey *)PK
                       privateKey:(const MKMPrivateKey *)SK {
    if (self = [super init]) {
        NSAssert([PK isMatch:SK], @"PK not match SK");
        self.privateKey = SK;
        self.publicKey = PK;
    }
    return self;
}

- (const NSString *)algorithm {
    return _publicKey.algorithm;
}

- (NSData *)storeKey:(const NSString *)passphrase {
    NSData *SK = nil;
    // TODO: encrypt private key with passphrase
    return SK;
}

@end
