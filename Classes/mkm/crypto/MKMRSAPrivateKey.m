//
//  MKMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAPublicKey.h"

#import "MKMRSAPrivateKey.h"

@interface MKMRSAPrivateKey () {
    
    SecKeyRef _privateKeyRef;
    
    MKMRSAPublicKey *_publicKey;
}

@property (nonatomic) NSUInteger keySizeInBits;

@property (strong, nonatomic) NSString *privateContent;

@property (nonatomic) SecKeyRef privateKeyRef;

@end

@implementation MKMRSAPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error");
        
        // lazy
        _keySizeInBits = 0;
        _privateContent = nil;
        _privateKeyRef = NULL;
        
        _publicKey = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    if (_privateKeyRef) {
        CFRelease(_privateKeyRef);
        _privateKeyRef = NULL;
    }
    
    //[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    MKMRSAPrivateKey *key = [super copyWithZone:zone];
    if (key) {
        key.keySizeInBits = _keySizeInBits;
        key.privateContent = _privateContent;
        key.privateKeyRef = _privateKeyRef;
    }
    return key;
}

- (NSUInteger)keySizeInBits {
    while (_keySizeInBits == 0) {
        if (_privateKeyRef || self.privateContent) {
            size_t bytes = SecKeyGetBlockSize(self.privateKeyRef);
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

- (NSString *)privateContent {
    if (!_privateContent) {
        // RSA key data
        NSString *data = [_storeDictionary objectForKey:@"data"];
        if (!data) {
            data = [_storeDictionary objectForKey:@"content"];
        }
        if (data) {
            _privateContent = RSAPrivateKeyContentFromNSString(data);
        }
    }
    return _privateContent;
}

- (void)setPrivateKeyRef:(SecKeyRef)privateKeyRef {
    if (_privateKeyRef != privateKeyRef) {
        if (privateKeyRef) CFRetain(privateKeyRef);
        if (_privateKeyRef) CFRelease(_privateKeyRef);
        _privateKeyRef = privateKeyRef;
    }
}

- (SecKeyRef)privateKeyRef {
    while (!_privateKeyRef) {
        // 1. get private key from data content
        NSString *privateContent = self.privateContent;
        if (privateContent) {
            // key from data
            NSData *data = [privateContent base64Decode];
            _privateKeyRef = SecKeyRefFromPrivateData(data);
            break;
        }
        
        // 2. generate key pairs
        //[self generateKeys];
        NSAssert(!_publicKey, @"error");
        
        // 2.1. key size
        NSUInteger keySizeInBits = self.keySizeInBits;
        if (keySizeInBits == 0) {
            keySizeInBits = 1024;
        }
        // 2.2. prepare parameters
        NSDictionary *params;
        params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
                   (id)kSecAttrKeySizeInBits:@(keySizeInBits),
                   //(id)kSecAttrIsPermanent:@YES,
                   };
        // 2.3. generate
        CFErrorRef error = NULL;
        _privateKeyRef = SecKeyCreateRandomKey((CFDictionaryRef)params,
                                               &error);
        if (error) {
            NSAssert(!_privateKeyRef, @"error");
            NSAssert(false, @"failed to generate key: %@", error);
            break;
        }
        NSAssert(_privateKeyRef, @"error");
        
        // 2.4. key to data
        NSData *skData = NSDataFromSecKeyRef(_privateKeyRef);
        if (skData) {
            _privateContent = [skData base64Encode];
            [_storeDictionary setObject:_privateContent forKey:@"data"];
            [_storeDictionary setObject:@(keySizeInBits) forKey:@"keySize"];
        } else {
            NSAssert(false, @"error");
        }
        
        break;
    }
    return _privateKeyRef;
}

- (NSString *)publicContent {
    // RSA key data
    NSString *data = [_storeDictionary objectForKey:@"data"];
    if (!data) {
        data = [_storeDictionary objectForKey:@"content"];
    }
    if (data) {
        // get public key content from data
        NSRange range = [data rangeOfString:@"PUBLIC KEY"];
        if (range.location != NSNotFound) {
            // get public key from data string
            return RSAPublicKeyContentFromNSString(data);
        }
    }
    
    SecKeyRef privateKeyRef = self.privateKeyRef;
    if (privateKeyRef) {
        // get public key content from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
        NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
        return [publicKeyData base64Encode];
    }
    
    NSAssert(false, @"failed to get public content");
    return nil;
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            NSDictionary *dict = @{@"algorithm":self.algorithm,
                                   @"data"     :publicContent,
                                   };
            _publicKey = [[MKMRSAPublicKey alloc] initWithDictionary:dict];
        }
    }
    return _publicKey;
}

#pragma mark - Protocol

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSAssert(self.privateKeyRef != NULL, @"private key cannot be empty");
    NSAssert(ciphertext.length == (self.keySizeInBits/8), @"data error");
    NSData *plaintext = nil;
    
    CFErrorRef error = NULL;
    CFDataRef CT;
    CT = SecKeyCreateDecryptedData(self.privateKeyRef,
                                   kSecKeyAlgorithmRSAEncryptionPKCS1,
                                   (CFDataRef)ciphertext,
                                   &error);
    if (error) {
        NSAssert(!CT, @"error");
        NSAssert(false, @"error: %@", error);
    } else {
        NSAssert(CT, @"decrypted data should not be empty");
        plaintext = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(plaintext, @"decrypt failed");
    return plaintext;
}

- (NSData *)sign:(const NSData *)data {
    NSAssert(self.privateKeyRef != NULL, @"private key cannot be empty");
    NSAssert(data.length > 0, @"data cannot be empty");
    if (data.length > (self.keySizeInBits/8 - 11)) {
        NSAssert(false, @"data too long");
        // if data too long, only sign the digest of plaintext
        // actually you can do it before calling sign/verify
        data = [data sha256d];
    }
    NSData *signature = nil;
    
    CFErrorRef error = NULL;
    CFDataRef CT;
    CT = SecKeyCreateSignature(self.privateKeyRef,
                               kSecKeyAlgorithmRSASignatureDigestPKCS1v15Raw,
                               (CFDataRef)data,
                               &error);
    if (error) {
        NSAssert(!CT, @"error");
        NSAssert(false, @"error: %@", error);
    } else {
        NSAssert(CT, @"signature should not be empty");
        signature = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(signature, @"sign failed");
    return signature;
}

@end

@implementation MKMRSAPrivateKey (PersistentStore)

static const NSString *s_application_tag = @"net.mingkeming.rsa.private";

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMRSAPrivateKey *SK = nil;
    
    NSString *label = [identifier copy];
    NSData *tag = [s_application_tag data];
    
    NSDictionary *query;
    query = @{(id)kSecClass               :(id)kSecClassKey,
              (id)kSecAttrApplicationLabel:label,
              (id)kSecAttrApplicationTag  :tag,
              (id)kSecAttrKeyType         :(id)kSecAttrKeyTypeRSA,
              (id)kSecAttrKeyClass        :(id)kSecAttrKeyClassPrivate,
              (id)kSecAttrSynchronizable  :(id)kCFBooleanTrue,
              
              (id)kSecMatchLimit          :(id)kSecMatchLimitOne,
              (id)kSecReturnRef           :(id)kCFBooleanTrue,
              };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status == errSecSuccess) { // noErr
        // private key
        SecKeyRef privateKeyRef = (SecKeyRef)result;
        NSData *skData = NSDataFromSecKeyRef(privateKeyRef);
        // public key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
        NSData *pkData = NSDataFromSecKeyRef(publicKeyRef);
        
        NSString *algorithm = @"RSA";
        NSString *pkFmt = @"-----BEGIN PUBLIC KEY----- %@ -----END PUBLIC KEY-----";
        NSString *skFmt = @"-----BEGIN RSA PRIVATE KEY----- %@ -----END RSA PRIVATE KEY-----";
        NSString *pkc = [NSString stringWithFormat:pkFmt, [pkData base64Encode]];
        NSString *skc = [NSString stringWithFormat:skFmt, [skData base64Encode]];
        NSString *content = [pkc stringByAppendingString:skc];
        NSDictionary *keyInfo = @{@"algorithm":algorithm,
                                  @"data"     :content,
                                  };
        SK = [[MKMRSAPrivateKey alloc] initWithDictionary:keyInfo];
    }
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    
    return SK;
}

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier {
    if (!_privateKeyRef) {
        NSAssert(false, @"_privateKeyRef cannot be empty");
        return NO;
    }
    
    NSString *label = [identifier copy];
    NSData *tag = [s_application_tag data];
    
    NSDictionary *query;
    query = @{(id)kSecClass               :(id)kSecClassKey,
              (id)kSecAttrApplicationLabel:label,
              (id)kSecAttrApplicationTag  :tag,
              (id)kSecAttrKeyType         :(id)kSecAttrKeyTypeRSA,
              (id)kSecAttrKeyClass        :(id)kSecAttrKeyClassPrivate,
              (id)kSecAttrSynchronizable  :(id)kCFBooleanTrue,
              
              (id)kSecMatchLimit          :(id)kSecMatchLimitOne,
              (id)kSecReturnRef           :(id)kCFBooleanTrue,
              };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status == errSecSuccess) { // noErr
        // already exists, delete it firest
        NSMutableDictionary *mQuery = [query mutableCopy];
        [mQuery removeObjectForKey:(id)kSecMatchLimit];
        [mQuery removeObjectForKey:(id)kSecReturnRef];
        
        status = SecItemDelete((CFDictionaryRef)mQuery);
    }
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    
    // add key item
    NSMutableDictionary *attributes = [query mutableCopy];
    [attributes removeObjectForKey:(id)kSecMatchLimit];
    [attributes removeObjectForKey:(id)kSecReturnRef];
    [attributes setObject:(__bridge id)_privateKeyRef forKey:(id)kSecValueRef];
    
    status = SecItemAdd((CFDictionaryRef)attributes, &result);
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    if (status == errSecSuccess) {
        return YES;
    } else {
        NSAssert(false, @"failed to update key");
        return NO;
    }
}

@end
