//
//  MKMRSAPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAPublicKey.h"

SecKeyRef SecKeyRefFromNSData(const NSData *data, NSUInteger size, BOOL isPublic) {
    // Set the private key query dictionary.
    CFStringRef keyClass;
    keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate;
    NSDictionary * dict;
    dict = @{(id)kSecAttrKeyType      : (id)kSecAttrKeyTypeRSA,
             (id)kSecAttrKeyClass     : (__bridge id)keyClass,
             (id)kSecAttrKeySizeInBits: @(size)};
    CFErrorRef error = NULL;
    SecKeyRef keyRef = SecKeyCreateWithData((CFDataRef)data,
                                            (CFDictionaryRef)dict,
                                            &error);
    assert(error == NULL);
    return keyRef;
}

NSData *NSDataFromSecKeyRef(SecKeyRef keyRef) {
    CFErrorRef error = NULL;
    CFDataRef dataRef = SecKeyCopyExternalRepresentation(keyRef, &error);
    assert(error == NULL);
    return (__bridge NSData *)(dataRef);
}

NSString *RSAKeyDataFromNSString(const NSString *content, BOOL isPublic) {
    NSString *sTag, *eTag;
    NSRange spos, epos;
    NSString *key = [content copy];
    NSString *tag = isPublic ? @"PUBLIC" : @"PRIVATE";
    
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

@interface MKMRSAPublicKey () {
    
    NSUInteger _keySize;
    SecKeyRef _publicKeyRef;
}

@property (strong, nonatomic) NSString *publicContent;

@end

@implementation MKMRSAPublicKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    NSAssert([algor isEqualToString:ACAlgorithmRSA], @"algorithm error");
    // RSA key size
    NSNumber *keySize = [info objectForKey:@"size"];
    if (!keySize) {
        keySize = [info objectForKey:@"keySize"];
    }
    // RSA key data
    NSString *data = [info objectForKey:@"data"];
    if (!data) {
        data = [info objectForKey:@"content"];
    }
    
    if (self = [super initWithDictionary:info]) {
        // key size
        if (keySize) {
            _keySize = [keySize unsignedIntegerValue];
        } else {
            _keySize = 1024;
        }
        
        // public key data
        self.publicContent = RSAKeyDataFromNSString(data, YES);
    }
    
    return self;
}

- (void)setPublicContent:(NSString *)publicContent {
    if (![_publicContent isEqualToString:publicContent]) {
        _publicKeyRef = SecKeyRefFromNSData([publicContent base64Decode],
                                            _keySize, YES);
        
        [_storeDictionary setObject:publicContent forKey:@"data"];
        [_storeDictionary removeObjectForKey:@"content"];
        _publicContent = [publicContent copy];
    }
}

- (NSData *)encrypt:(const NSData *)plaintext {
    NSAssert([plaintext length] > 0, @"plaintext cannot be empty");
    NSAssert([plaintext length] <= (_keySize/8 - 11), @"plaintext too long");
    NSAssert(_publicKeyRef != NULL, @"public key cannot be empty");
    NSData *ciphertext = nil;
    
    // buffer
    size_t bufferSize = SecKeyGetBlockSize(_publicKeyRef);
    uint8_t *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize * sizeof(uint8_t));
    
    // encrypt using the public key.
    OSStatus status = SecKeyEncrypt(_publicKeyRef,
                                    kSecPaddingPKCS1,
                                    [plaintext bytes],
                                    [plaintext length],
                                    buffer,
                                    &bufferSize
                                    );
    NSAssert(status == noErr, @"Error, OSStatus: %d.", status);
    
    // build up ciphertext
    ciphertext = [[NSData alloc] initWithBytesNoCopy:buffer
                                              length:bufferSize
                                        freeWhenDone:YES];
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    NSAssert([plaintext length] > 0, @"plaintext cannot be empty");
    NSAssert([plaintext length] <= (_keySize/8 - 11), @"plaintext too long");
    NSAssert([ciphertext length] > 0, @"signature cannot be empty");
    NSAssert([ciphertext length] <= (_keySize/8), @"signature too long");
    NSAssert(_publicKeyRef != NULL, @"public key cannot be empty");
    BOOL match = NO;
    
    // RSA verify
    OSStatus sanityCheck = noErr;
    sanityCheck = SecKeyRawVerify(_publicKeyRef,
                                  kSecPaddingPKCS1,
                                  [plaintext bytes],
                                  [plaintext length],
                                  [ciphertext bytes],
                                  [ciphertext length]
                                  );
    
    match = (sanityCheck == noErr);

    return match;
}

@end
