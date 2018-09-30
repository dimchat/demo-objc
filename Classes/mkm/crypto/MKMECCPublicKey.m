//
//  MKMECCPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMECCPublicKey.h"

@implementation MKMECCPublicKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmECC], @"algorithm error");
    if (self = [super initWithDictionary:info]) {
        // TODO: ECC algorithm arguments
    }
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: ECC encrypt
    ciphertext = [[plaintext base58Encode] data];
    // FIXME: above is just for test, please implement it
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    
    // TODO: ECC verify
    NSData *temp = [[ciphertext UTF8String] base58Decode];
    match = [plaintext isEqualToData:temp];
    // FIXME: above is just for test, please implement it
    
    return match;
}

@end
