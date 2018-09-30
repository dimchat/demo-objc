//
//  MKMKeyStore.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

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
    const NSDictionary *info;
    const MKMPrivateKey *SK;
    const MKMPublicKey *PK;
    
    info = @{@"algorithm":name};
    SK = [[MKMPrivateKey alloc] initWithAlgorithm:name keyInfo:info];
    PK = [SK publicKey];
    
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

- (NSData *)privateKeyStoredWithPassword:(const MKMSymmetricKey *)scKey {
    NSData *KS = nil;
    
    NSData *data = [_privateKey jsonData];
    KS = [scKey encrypt:data];
    
    return KS;
}

@end
