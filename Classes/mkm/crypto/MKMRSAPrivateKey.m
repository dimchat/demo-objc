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
        if (_privateKeyRef) {
            CFRetain(_privateKeyRef);
            key.privateKeyRef = _privateKeyRef;
        }
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
            _privateContent = RSAPrivateKeyDataFromNSString(data);
        }
    }
    return _privateContent;
}

- (BOOL)generateKeys {
    // key size
    NSUInteger keySizeInBits = self.keySizeInBits;
    if (keySizeInBits == 0) {
        keySizeInBits = 1024;
    }
    
    SecKeyRef publicKeyRef;
    SecKeyRef privateKeyRef;
    NSDictionary *params;
    params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
               (id)kSecAttrKeySizeInBits:@(keySizeInBits),
               (id)kSecPrivateKeyAttrs  :@{(id)kSecAttrIsPermanent:@YES},
               (id)kSecPublicKeyAttrs   :@{(id)kSecAttrIsPermanent:@YES},
               };
    OSStatus status;
    // generate
    status = SecKeyGeneratePair((CFDictionaryRef)params,
                                &publicKeyRef, &privateKeyRef);
    if (status != noErr || publicKeyRef == NULL || privateKeyRef == NULL) {
        NSAssert(false, @"failed to generate keys");
        return NO;
    }
    
    // private key data
    NSData *privateKeyData = NSDataFromSecKeyRef(privateKeyRef);
    if (privateKeyData) {
        _privateKeyRef = privateKeyRef;
        _privateContent = [privateKeyData base64Encode];
        _publicKey = nil;
        [_storeDictionary setObject:_privateContent forKey:@"data"];
        [_storeDictionary setObject:@(keySizeInBits) forKey:@"keySize"];
        return YES;
    }
    
    NSAssert(false, @"error");
    return NO;
}

- (SecKeyRef)privateKeyRef {
    if (!_privateKeyRef) {
        NSString *privateContent = self.privateContent;
        if (privateContent) {
            // key from data
            NSData *data = [privateContent base64Decode];
            _privateKeyRef = SecKeyRefFromNSData(data, NO);
        } else {
            // Generate key pairs
            [self generateKeys];
        }
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
            return RSAPublicKeyDataFromNSString(data);
        }
    }
    
    SecKeyRef privateKeyRef = self.privateKeyRef;
    if (privateKeyRef) {
        // get public key content from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
        NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
        return [publicKeyData base64Encode];
    }
    
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
    NSAssert([ciphertext length] > 0, @"ciphertext cannot be empty");
    NSAssert([ciphertext length] <= (self.keySizeInBits/8), @"ciphertext too long");
    NSAssert(_privateKeyRef != NULL, @"private key cannot be empty");
    NSData *plaintext = nil;
    
    // buffer
    size_t bufferSize = SecKeyGetBlockSize(_privateKeyRef);
    uint8_t *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize * sizeof(uint8_t));
    
    // decrypt using the private key
    OSStatus status = SecKeyDecrypt(_privateKeyRef,
                                    kSecPaddingPKCS1,
                                    [ciphertext bytes],
                                    [ciphertext length],
                                    buffer,
                                    &bufferSize
                                    );
    NSAssert(status == noErr, @"Error, OSStatus: %d.", status);
    
    // build up plaintext
    plaintext = [[NSData alloc] initWithBytesNoCopy:buffer
                                             length:bufferSize
                                       freeWhenDone:YES];
    
    return plaintext;
}

- (NSData *)sign:(const NSData *)data {
    NSAssert([data length] > 0, @"data cannot be empty");
    //NSAssert([data length] <= (self.keySizeInBits/8 - 11), @"data too long");
    NSAssert(self.privateKeyRef != NULL, @"private key cannot be empty");
    NSData *signature = nil;
    
    if (data.length > (self.keySizeInBits/8 - 11)) {
        // if data too long, only sign the digest of plaintext
        // actually you can do it before calling sign/verify
        data = [data sha256d];
    }
    
    // buffer
    size_t bufferSize = SecKeyGetBlockSize(self.privateKeyRef);
    uint8_t *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize * sizeof(uint8_t));
    
    // sign with the private key
    OSStatus status = SecKeyRawSign(self.privateKeyRef,
                                kSecPaddingPKCS1,
                                [data bytes],
                                [data length],
                                buffer,
                                &bufferSize
                                );
    NSAssert(status == noErr, @"Error, OSStatus: %d.", status);
    
    // buid up signature
    signature = [[NSData alloc] initWithBytesNoCopy:buffer
                                             length:bufferSize
                                       freeWhenDone:YES];
    
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
