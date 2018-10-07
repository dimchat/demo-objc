//
//  MKMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "RSA.h"

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMRSAPrivateKey.h"

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

@interface MKMRSAPrivateKey () {
    
    MKMPublicKey *_publicKey;
}

@property (strong, nonatomic) NSString *privateContent;

@end

@implementation MKMRSAPrivateKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algorithm = [info objectForKey:@"algorithm"];
    NSAssert([algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error");
    // RSA key data
    NSString *data = [info objectForKey:@"data"];
    if (!data) {
        data = [info objectForKey:@"content"];
    }
    if (!data) {
        // TODO: generate RSA key pair data
    }
    
    if (self = [super initWithDictionary:info]) {
        // private key
        self.privateContent = rsa_key_data(data, @"PRIVATE");
        
        // public key
        NSRange range = [data rangeOfString:@"PUBLIC KEY"];
        NSAssert(range.location != NSNotFound, @"PUBLIC KEY data not found");
        if (range.location != NSNotFound) {
            NSString *PK = rsa_key_data(data, @"PUBLIC");
            NSDictionary *pDict = @{@"algorithm":algorithm, @"data":PK};
            _publicKey = [[MKMPublicKey alloc] initWithAlgorithm:algorithm
                                                         keyInfo:pDict];
        }
    }
    
    return self;
}

- (void)setPrivateContent:(NSString *)privateContent {
    if (![_privateContent isEqualToString:privateContent]) {
        [_storeDictionary setObject:privateContent forKey:@"data"];
        [_storeDictionary removeObjectForKey:@"content"];
        _privateContent = [privateContent copy];
    }
}

- (const MKMPublicKey *)publicKey {
    return _publicKey;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSData *plaintext = nil;
    
    // RSA encrypt
    plaintext = [RSA decryptData:[ciphertext copy]
                      privateKey:_privateContent];
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)plaintext {
    NSData *ciphertext = nil;
    
    // RSA encrypt
    ciphertext = [RSA encryptData:[plaintext copy]
                       privateKey:_privateContent];
    
    return ciphertext;
}

@end
