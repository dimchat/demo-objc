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

@interface MKMRSAPublicKey () {
    
    NSUInteger _keySize;
    SecKeyRef _publicKeyRef;
}

@property (strong, nonatomic) NSString *publicContent;

@end

@implementation MKMRSAPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([_algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error");
        //keyInfo = _storeDictionary;
        
        // RSA key data
        NSString *data = [keyInfo objectForKey:@"data"];
        if (!data) {
            data = [keyInfo objectForKey:@"content"];
        }
        self.publicContent = RSAKeyDataFromNSString(data, YES);
    }
    
    return self;
}

- (void)setPublicContent:(NSString *)publicContent {
    if (publicContent) {
        if (![_publicContent isEqualToString:publicContent]) {
            // key ref & size
            _publicKeyRef = SecKeyRefFromNSData([publicContent base64Decode], YES);
            _keySize = SecKeyGetBlockSize(_publicKeyRef) * sizeof(uint8_t) * 8;
            
            // key data content
            [_storeDictionary setObject:publicContent forKey:@"data"];
            [_storeDictionary removeObjectForKey:@"content"];
            _publicContent = [publicContent copy];
        }
    } else {
        // clear key ref
        if (_publicKeyRef) {
            CFRelease(_publicKeyRef);
            _publicKeyRef = NULL;
        }
        
        // clear key data content
        _publicContent = nil;
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
    
    match = (sanityCheck == errSecSuccess);

    return match;
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
