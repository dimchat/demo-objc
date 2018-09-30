//
//  MKMRSAPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAPublicKey.h"

@implementation MKMRSAPublicKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmRSA], @"algorithm error");
    if (self = [super initWithDictionary:info]) {
        // TODO: RSA algorithm arguments
    }
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: RSA encrypt
    ciphertext = [[plaintext base64Encode] data];
    // FIXME: above is just for test, please implement it
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    
    // TODO: RSA verify
    NSData *temp = [[ciphertext UTF8String] base64Decode];
    match = [plaintext isEqualToData:temp];
    // FIXME: above is just for test, please implement it
    
    return match;
}

@end
