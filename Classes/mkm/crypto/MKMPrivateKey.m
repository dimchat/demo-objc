//
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMRSAPrivateKey.h"
#import "MKMECCPrivateKey.h"

#import "MKMPrivateKey.h"

@implementation MKMPrivateKey

- (instancetype)init {
    self = [self initWithAlgorithm:ACAlgorithmRSA];
    return self;
}

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK {
    if (self = [self initWithJSONString:json]) {
        NSAssert([PK isMatch:self], @"PK not match SK");
    }
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    NSAssert([algorithm isEqualToString:[dict objectForKey:@"algorithm"]], @"error");
    
    if ([self isMemberOfClass:[MKMPrivateKey class]]) {
        if ([algorithm isEqualToString:ACAlgorithmECC]) {
            self = [[MKMECCPrivateKey alloc] initWithAlgorithm:algorithm keyInfo:dict];
        } else if ([algorithm isEqualToString:ACAlgorithmRSA]) {
            self = [[MKMRSAPrivateKey alloc] initWithAlgorithm:algorithm keyInfo:dict];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else {
        NSAssert([[self class] isSubclassOfClass:[MKMPrivateKey class]], @"error");
        // subclass
        self = [super initWithAlgorithm:algorithm keyInfo:info];
    }
    
    return self;
}

- (BOOL)isEqual:(const MKMPrivateKey *)aKey {
    // 1. if the two key has the same content, return YES
    if ([super isEqual:aKey]) {
        return YES;
    }
    // 2. try to verify by public key
    return [aKey.publicKey isMatch:self];
}

- (const MKMPublicKey *)publicKey {
    // implements in subclass
    return nil;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    // implements in subclass
    return nil;;
}

- (NSData *)sign:(const NSData *)plaintext {
    // implements in subclass
    return nil;;
}

@end
