//
//  NSData+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "base58.h"

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"

#import "NSData+Crypto.h"

@implementation NSData (Encode)

- (NSString *)hexEncode {
    NSMutableString *output = nil;
    
    const char *bytes = (const char *)[self bytes];
    NSUInteger len = [self length];
    output = [[NSMutableString alloc] initWithCapacity:(len*2)];
    for (int i = 0; i < len; ++i) {
        [output appendFormat:@"%02x", (unsigned char)bytes[i]];
    }
    
    return output;
}

- (NSString *)base58Encode {
    NSString *output = nil;
    
    const unsigned char * pbegin = (const unsigned char *)[self bytes];
    const unsigned char * pend = pbegin + [self length];
    std::string str = EncodeBase58(pbegin, pend);
    output = [[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding];
    
    return output;
}

- (NSString *)base64Encode {
    NSDataBase64EncodingOptions opt;
    opt = NSDataBase64EncodingEndLineWithCarriageReturn;
    return [self base64EncodedStringWithOptions:opt];
}

@end

@implementation NSData (Hash)

- (NSData *)md5 {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha1 {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

- (NSData *)sha224 {
    unsigned char digest[CC_SHA224_DIGEST_LENGTH];
    CC_SHA224([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
}

- (NSData *)sha256 {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)sha384 {
    unsigned char digest[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
}

- (NSData *)sha512 {
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
}

- (NSData *)ripemd160 {
    NSData *output = nil;
    // TODO: RIPEMD-160 algorithm
    output = [self sha1];
    // FIXME: above is just for test, please implement it
    return output;
}

@end

@implementation NSData (AES)

- (NSData *)aesEncrypt:(const NSString *)passphrase {
    NSData *output = nil;
    // TODO: AES algorithm
    output = [[self base64Encode] data];
    // FIXME: above is just for test, please implement it
    return output;
}

- (NSData *)aesDecrypt:(const NSString *)passphrase {
    NSData *output = nil;
    // TODO: AES algorithm
    output = [[self UTF8String] base64Decode];
    // FIXME: above is just for test, please implement it
    return output;
}

@end
