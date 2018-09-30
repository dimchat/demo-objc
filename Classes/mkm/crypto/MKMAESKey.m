//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

@implementation MKMAESKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:SCAlgorithmAES], @"algorithm error");
    
    if (self = [super initWithDictionary:info]) {
        // TODO: AES algorithm arguments
    }
    
    return self;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // TODO: AES algorithm
    ciphertext = [[plaintext base64Encode] data];
    // FIXME: above is just for test, please implement it
    
    return ciphertext;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // TODO: AES algorithm
    plaintext = [[ciphertext UTF8String] base64Decode];
    // FIXME: above is just for test, please implement it
    
    return plaintext;
}

@end
