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

#import "MKMRSAPrivateKey.h"

#import "MKMRSAPublicKey.h"

SecKeyRef SecKeyRefFromNSData(const NSData *data, BOOL isPublic) {
    // Set the private key query dictionary.
    CFStringRef keyClass;
    keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate;
    NSDictionary * dict;
    dict = @{(id)kSecAttrKeyType :(id)kSecAttrKeyTypeRSA,
             (id)kSecAttrKeyClass:(__bridge id)keyClass,
             };
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

NSString *RSAPublicKeyDataFromNSString(const NSString *content) {
    return RSAKeyDataFromNSString(content, YES);
}

NSString *RSAPrivateKeyDataFromNSString(const NSString *content) {
    return RSAKeyDataFromNSString(content, NO);
}

@interface MKMRSAPublicKey ()

@property (nonatomic) NSUInteger keySizeInBits;

@property (strong, nonatomic) NSString *publicContent;

@property (nonatomic) SecKeyRef publicKeyRef;

@end

@implementation MKMRSAPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error");
        
        // lazy
        _keySizeInBits = 0;
        _publicContent = nil;
        _publicKeyRef = NULL;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    if (_publicKeyRef) {
        CFRelease(_publicKeyRef);
        _publicKeyRef = NULL;
    }
    
    //[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    MKMRSAPublicKey *key = [super copyWithZone:zone];
    if (key) {
        key.keySizeInBits = _keySizeInBits;
        key.publicContent = _publicContent;
        if (_publicKeyRef) {
            CFRetain(_publicKeyRef);
            key.publicKeyRef = _publicKeyRef;
        }
    }
    return key;
}

- (NSUInteger)keySizeInBits {
    while (_keySizeInBits == 0) {
        if (_publicKeyRef || self.publicContent) {
            size_t bytes = SecKeyGetBlockSize(self.publicKeyRef);
            _keySizeInBits = bytes * sizeof(uint8_t) * 8;
            break;
        }
        
        NSNumber *keySize;
        keySize = [_storeDictionary objectForKey:@"keySize"];
        if (keySize) {
            _keySizeInBits = keySize.unsignedIntegerValue;
            break;
        }
        keySize = [_storeDictionary objectForKey:@"size"];
        if (keySize) {
            _keySizeInBits = keySize.unsignedIntegerValue;
            break;
        }
        
        break;
    }
    return _keySizeInBits;
}

- (NSString *)publicContent {
    if (!_publicContent) {
        // RSA key data
        NSString *data = [_storeDictionary objectForKey:@"data"];
        if (!data) {
            data = [_storeDictionary objectForKey:@"content"];
        }
        if (data) {
            _publicContent = RSAPublicKeyDataFromNSString(data);
        }
    }
    return _publicContent;
}

- (SecKeyRef)publicKeyRef {
    if (!_publicKeyRef) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            // key from data
            NSData *data = [publicContent base64Decode];
            _publicKeyRef = SecKeyRefFromNSData(data, YES);
        }
    }
    return _publicKeyRef;
}

#pragma mark - Protocol

- (NSData *)encrypt:(const NSData *)plaintext {
    NSAssert(self.publicKeyRef != NULL, @"public key cannot be empty");
    NSAssert(plaintext.length > 0, @"plaintext cannot be empty");
    NSAssert(plaintext.length <= (self.keySizeInBits/8 - 11), @"data too long");
    NSData *ciphertext = nil;
    
    CFErrorRef error = NULL;
    CFDataRef CT;
    CT = SecKeyCreateEncryptedData(self.publicKeyRef,
                                   kSecKeyAlgorithmRSAEncryptionPKCS1,
                                   (__bridge CFDataRef)plaintext,
                                   &error);
    if (error) {
        NSAssert(false, @"error: %@", error);
    } else {
        NSAssert(CT, @"encrypted should not be empty");
        ciphertext = [[NSData alloc] initWithData:(__bridge NSData *)CT];
    }
    CFRelease(CT);
    
    return ciphertext;
}

- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature {
    NSAssert(self.publicKeyRef != NULL, @"public key cannot be empty");
    NSAssert(signature.length == (self.keySizeInBits/8), @"signature error");
    NSAssert(data.length > 0, @"data cannot be empty");
    if (data.length > (self.keySizeInBits/8 - 11)) {
        NSAssert(false, @"data too long");
        // if data too long, only sign the digest of plaintext
        // actually you can do it before calling sign/verify
        data = [data sha256d];
    }
    BOOL OK = NO;
    
    CFErrorRef error = NULL;
    OK = SecKeyVerifySignature(self.publicKeyRef,
                               kSecKeyAlgorithmRSASignatureDigestPKCS1v15Raw,
                               (__bridge CFDataRef)data,
                               (__bridge CFDataRef)signature,
                               &error);
    if (error) {
        NSAssert(!OK, @"verify error");
        NSAssert(false, @"error: %@", error);
    }
    
    return OK;
}

@end

@implementation MKMRSAPublicKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMRSAPublicKey *PK = nil;
    
    // TODO: load RSA public key from persistent store
    
    // finally, try by private key
    MKMRSAPrivateKey *SK = [MKMRSAPrivateKey loadKeyWithIdentifier:identifier];
    PK = (MKMRSAPublicKey *)SK.publicKey;
    
    return PK;
}

@end
