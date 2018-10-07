//
//  MKMRSAPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "RSA.h"

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAPublicKey.h"

static NSString *rsa_key_data(const NSString *content, const NSString *tag) {
    NSString *sTag, *eTag;
    NSRange spos, epos;
    NSString *key = [content copy];
    tag = [tag uppercaseString];
    
    sTag = [NSString stringWithFormat:@"-----BEGIN RSA %@ KEY-----", tag];
    eTag = [NSString stringWithFormat:@"-----END RSA %@ KEY-----", tag];
    spos = [key rangeOfString:sTag];
    if (spos.length > 0) {
        epos = [key rangeOfString:eTag];
    } else {
        sTag = [NSString stringWithFormat:@"-----BEGIN %@ KEY-----", tag];
        eTag = [NSString stringWithFormat:@"-----END %@ KEY-----", tag];
        spos = [key rangeOfString:sTag];
        epos = [key rangeOfString:eTag];
    }
    
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    return key;
}

@interface MKMRSAPublicKey ()

@property (strong, nonatomic) NSString *publicContent;

@end

@implementation MKMRSAPublicKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmRSA], @"algorithm error");
    
    if (self = [super initWithDictionary:info]) {
        // RSA algorithm arguments
        
        NSString *data = [info objectForKey:@"data"];
        if (!data) {
            data = [info objectForKey:@"content"];
        }
        self.publicContent = rsa_key_data(data, @"PUBLIC");
    }
    
    return self;
}

- (void)setPublicContent:(NSString *)publicContent {
    if (![_publicContent isEqualToString:publicContent]) {
        [_storeDictionary setObject:publicContent forKey:@"data"];
        [_storeDictionary removeObjectForKey:@"content"];
        _publicContent = [publicContent copy];
    }
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // RSA encrypt
    ciphertext = [RSA encryptData:[plaintext copy]
                        publicKey:_publicContent];
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    BOOL match = NO;
    
    // RSA verify
    NSData *temp = [RSA decryptData:[ciphertext copy]
                          publicKey:_publicContent];
    match = [plaintext isEqualToData:temp];
    
    return match;
}

@end
