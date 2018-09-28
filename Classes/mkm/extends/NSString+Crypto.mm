//
//  NString+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "base58.h"

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

@implementation NSString (Decode)

- (NSData *)hexDecode {
    NSData *output = nil;
    // TODO: decode hex string
    
    return output;
}

- (NSData *)base58Decode {
    NSData *output = nil;
    
    const char * cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    std::vector<unsigned char> vch;
    DecodeBase58(cstr, vch);
    std::string str(vch.begin(), vch.end());
    output = [NSData dataWithBytes:str.c_str() length:str.size()];
    
    return output;
}

- (NSData *)base64Decode {
    NSDataBase64DecodingOptions opt;
    opt = NSDataBase64DecodingIgnoreUnknownCharacters;
    return [[NSData alloc] initWithBase64EncodedString:self options:opt];
}

@end
