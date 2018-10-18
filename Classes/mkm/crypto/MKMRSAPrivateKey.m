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
    
    NSUInteger _keySize;
    SecKeyRef _privateKeyRef;
    
    MKMRSAPublicKey *_publicKey;
}

@property (strong, nonatomic) NSString *privateContent;

@end

@implementation MKMRSAPrivateKey

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
        
        NSString *privateContent = nil;
        NSData *privateKeyData = nil;
        SecKeyRef privateKeyRef = NULL;
        NSString *publicContent = nil;
        SecKeyRef publicKeyRef = NULL;
        if (data) {
            // private key data
            self.privateContent = RSAKeyDataFromNSString(data, NO);
            
            // public key data
            NSRange range = [data rangeOfString:@"PUBLIC KEY"];
            if (range.location != NSNotFound) {
                // get public key from data string
                publicContent = RSAKeyDataFromNSString(data, YES);
                NSDictionary *dict = @{@"algorithm":_algorithm,
                                       @"data"     :publicContent,
                                       };
                _publicKey = [[MKMRSAPublicKey alloc] initWithDictionary:dict];
            }
        } else /* data == nil */ {
            // RSA key size
            NSNumber *keySize = [keyInfo objectForKey:@"keySize"];
            if (!keySize) {
                keySize = [keyInfo objectForKey:@"size"];
            }
            if (keySize) {
                _keySize = keySize.unsignedIntegerValue;
            } else {
                _keySize = 1024;
                [_storeDictionary setObject:@(_keySize) forKey:@"keySize"];
            }
            
            // Generate key pairs
            NSDictionary *params;
            params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
                       (id)kSecAttrKeySizeInBits:@(_keySize),
                       (id)kSecPrivateKeyAttrs  :@{(id)kSecAttrIsPermanent:@YES},
                       (id)kSecPublicKeyAttrs   :@{(id)kSecAttrIsPermanent:@YES},
                       };
            OSStatus status;
            status = SecKeyGeneratePair((CFDictionaryRef)params,
                                        &publicKeyRef, &privateKeyRef);
            NSAssert(status==noErr && publicKeyRef!=NULL && privateKeyRef!=NULL,
                     @"failed to generate keys");
            _privateKeyRef = privateKeyRef;
            
            // private key data
            privateKeyData = NSDataFromSecKeyRef(privateKeyRef);
            privateContent = [privateKeyData base64Encode];
            if (privateContent) {
                [_storeDictionary setObject:privateContent forKey:@"data"];
                _privateContent = privateContent;
            }
        }
    }
    
    return self;
}

- (void)setPrivateContent:(NSString *)privateContent {
    if (privateContent) {
        if (![_privateContent isEqualToString:privateContent]) {
            // key ref & size
            _privateKeyRef = SecKeyRefFromNSData([privateContent base64Decode], NO);
            _keySize = SecKeyGetBlockSize(_privateKeyRef) * sizeof(uint8_t) * 8;
            
            // key data content
            _privateContent = [privateContent copy];
            [_storeDictionary setObject:privateContent forKey:@"data"];
            [_storeDictionary removeObjectForKey:@"content"];
            [_storeDictionary setObject:@(_keySize) forKey:@"keySize"];
        }
    } else {
        // clear key ref
        if (_privateKeyRef) {
            CFRelease(_privateKeyRef);
            _privateKeyRef = NULL;
        }
        
        // clear key data content
        _privateContent = nil;
    }
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey && _privateKeyRef) {
        // get public key data from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(_privateKeyRef);
        NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
        NSString *publicContent = [publicKeyData base64Encode];
        // create public key
        NSDictionary *keyInfo = @{@"algorithm":_algorithm,
                                  @"data"     :publicContent,
                                  };
        _publicKey = [[MKMRSAPublicKey alloc] initWithDictionary:keyInfo];
    }
    return _publicKey;
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSAssert([ciphertext length] > 0, @"ciphertext cannot be empty");
    NSAssert([ciphertext length] <= (_keySize/8), @"ciphertext too long");
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

- (NSData *)sign:(const NSData *)plaintext {
    NSAssert([plaintext length] > 0, @"plaintext cannot be empty");
    NSAssert([plaintext length] <= (_keySize/8 - 11), @"plaintext too long");
    NSAssert(_privateKeyRef != NULL, @"private key cannot be empty");
    NSData *ciphertext = nil;
    
    // buffer
    size_t bufferSize = SecKeyGetBlockSize(_privateKeyRef);
    uint8_t *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize * sizeof(uint8_t));
    
    // sign with the private key
    OSStatus status = SecKeyRawSign(_privateKeyRef,
                                kSecPaddingPKCS1,
                                [plaintext bytes],
                                [plaintext length],
                                buffer,
                                &bufferSize
                                );
    NSAssert(status == noErr, @"Error, OSStatus: %d.", status);
    
    // buid up signature
    ciphertext = [[NSData alloc] initWithBytesNoCopy:buffer
                                              length:bufferSize
                                        freeWhenDone:YES];
    
    return ciphertext;
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
