//
//  MKMPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"
#import "MKMRSAPublicKey.h"
#import "MKMECCPublicKey.h"

#import "MKMPublicKey.h"

@implementation MKMPublicKey

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [self initWithAlgorithm:ACAlgorithmRSA];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    NSAssert([algorithm isEqualToString:[dict objectForKey:@"algorithm"]], @"error");
    
    if ([self isMemberOfClass:[MKMPublicKey class]]) {
        // create instance with algorithm
        if ([algorithm isEqualToString:ACAlgorithmECC]) {
            self = [[MKMECCPublicKey alloc] initWithAlgorithm:algorithm keyInfo:dict];
        } else if ([algorithm isEqualToString:ACAlgorithmRSA]) {
            self = [[MKMRSAPublicKey alloc] initWithAlgorithm:algorithm keyInfo:dict];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else {
        NSAssert([[self class] isSubclassOfClass:[MKMPublicKey class]], @"error");
        // subclass
        self = [super initWithAlgorithm:algorithm keyInfo:info];
    }
    
    return self;
}

- (BOOL)isMatch:(const MKMPrivateKey *)SK {
    // 1. if the SK has the same public key, return YES
    if ([SK.publicKey isEqual:self]) {
        return YES;
    }
    // 2. try to verify the SK's signature
    NSString *promise = @"Moky loves May Lee forever!";
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = [SK sign:data];
    return [self verify:data signature:signature];
}

- (NSData *)encrypt:(const NSData *)plaintext {
    // implements in subclass
    return nil;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    // implements in subclass
    return NO;
}

@end
