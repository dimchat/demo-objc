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

#import "MKMRSAKeyHelper.h"
#import "MKMRSAPrivateKey.h"

#import "MKMRSAPublicKey.h"

@interface MKMRSAPublicKey () {
    
    SecKeyRef _publicKeyRef;
}

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
        key.publicKeyRef = _publicKeyRef;
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
            _publicContent = RSAPublicKeyContentFromNSString(data);
        }
    }
    return _publicContent;
}

- (void)setPublicKeyRef:(SecKeyRef)publicKeyRef {
    if (_publicKeyRef != publicKeyRef) {
        if (publicKeyRef) CFRetain(publicKeyRef);
        if (_publicKeyRef) CFRelease(_publicKeyRef);
        _publicKeyRef = publicKeyRef;
    }
}

- (SecKeyRef)publicKeyRef {
    if (!_publicKeyRef) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            // key from data
            NSData *data = [publicContent base64Decode];
            _publicKeyRef = SecKeyRefFromPublicData(data);
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
                                   (CFDataRef)plaintext,
                                   &error);
    if (error) {
        NSAssert(!CT, @"error");
        NSAssert(false, @"error: %@", error);
    } else {
        NSAssert(CT, @"encrypted should not be empty");
        ciphertext = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(ciphertext, @"encrypt failed");
    return ciphertext;
}

- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature {
    NSAssert(self.publicKeyRef != NULL, @"public key cannot be empty");
    NSAssert(signature.length == (self.keySizeInBits/8), @"signature error");
    NSAssert(data.length > 0, @"data cannot be empty");
    BOOL OK = NO;
    
    CFErrorRef error = NULL;
    OK = SecKeyVerifySignature(self.publicKeyRef,
                               kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256,
                               (CFDataRef)data,
                               (CFDataRef)signature,
                               &error);
    if (error) {
        NSAssert(!OK, @"error");
        //NSAssert(false, @"verify error: %@", error);
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
