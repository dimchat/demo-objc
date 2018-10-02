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

static inline char hex_char(char ch) {
    if (ch >= '0' && ch <= '9') {
        return ch - '0';
    }
    if (ch >= 'a' && ch <= 'f') {
        return ch - 'a' + 10;
    }
    if (ch >= 'A' && ch <= 'F') {
        return ch - 'A' + 10;
    }
    return 0;
}

@implementation NSString (Decode)

- (NSData *)hexDecode {
    NSMutableData *output = nil;
    
    NSString *str = [self copy];
    // 1. remove ' ', ':', '\n'
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // 2. skip '0x' prefix
    char ch0, ch1;
    NSUInteger pos = 0;
    NSUInteger len = [self length];
    if (len > 2) {
        ch0 = [str characterAtIndex:0];
        ch1 = [str characterAtIndex:1];
        if (ch0 == '0' && (ch1 == 'x' || ch1 == 'X')) {
            pos = 2;
        }
    }
    
    // 3. decode bytes
    output = [[NSMutableData alloc] initWithCapacity:(len/2)];
    unsigned char byte;
    for (; (pos + 1) < len; pos += 2) {
        ch0 = [str characterAtIndex:pos];
        ch1 = [str characterAtIndex:(pos + 1)];
        byte = hex_char(ch0) * 16 + hex_char(ch1);
        [output appendBytes:&byte length:1];
    }
    
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
