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

#import "MKMPublicKey.h"
#import "MKMRSAPublicKey.h"

#import "MKMRSAPrivateKey.h"

@interface MKMRSAPrivateKey () {
    
    NSUInteger _keySize;
    SecKeyRef _privateKeyRef;
    
    MKMPublicKey *_publicKey;
}

@property (strong, nonatomic) NSString *privateContent;

@end

@implementation MKMRSAPrivateKey

- (instancetype)initWithDictionary:(NSDictionary *)info {
    NSString *algorithm = [info objectForKey:@"algorithm"];
    NSAssert([algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error");
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
                NSDictionary *pDict = @{@"algorithm":algorithm,
                                        @"size":@(_keySize),
                                        @"data":publicContent};
                _publicKey = [[MKMPublicKey alloc] initWithAlgorithm:algorithm
                                                             keyInfo:pDict];
            }
        } else {
            // Generate key pairs
            NSDictionary *params;
            params = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                       (id)kSecAttrKeySizeInBits: @(_keySize),
                       (id)kSecPrivateKeyAttrs: @{(id)kSecAttrIsPermanent:@YES},
                       (id)kSecPublicKeyAttrs: @{(id)kSecAttrIsPermanent:@YES}
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
                [_storeDictionary setObject:@(_keySize) forKey:@"size"];
                [_storeDictionary setObject:privateContent forKey:@"data"];
                _privateContent = privateContent;
            }
        }
    }
    
    return self;
}

- (void)setPrivateContent:(NSString *)privateContent {
    if (![_privateContent isEqualToString:privateContent]) {
        _privateKeyRef = SecKeyRefFromNSData([privateContent base64Decode],
                                             _keySize, NO);
        
        [_storeDictionary setObject:privateContent forKey:@"data"];
        [_storeDictionary removeObjectForKey:@"content"];
        _privateContent = [privateContent copy];
    }
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey && _privateKeyRef) {
        // get public key data from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(_privateKeyRef);
        NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
        NSString *publicContent = [publicKeyData base64Encode];
        // create public key
        NSDictionary *pDict = @{@"algorithm": _algorithm,
                                @"size": @(_keySize),
                                @"data": publicContent};
        _publicKey = [[MKMPublicKey alloc] initWithAlgorithm:_algorithm
                                                     keyInfo:pDict];
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

+ (instancetype)loadKeyWithCode:(NSUInteger)code {
    MKMRSAPrivateKey *SK = nil;
    
    NSString *label = @"net.dim.rsa.private";
    NSString *tag = [NSString stringWithFormat:@"%010lu", code];
    
    NSDictionary *query = @{(id)kSecClass: (id)kSecClassKey,
                            (id)kSecAttrApplicationLabel: [label data],
                            (id)kSecAttrApplicationTag: [tag data],
                            (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                            (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                            (id)kSecAttrSynchronizable: (id)kCFBooleanTrue,
                            
                            (id)kSecMatchLimit: (id)kSecMatchLimitOne,
                            (id)kSecReturnRef: (id)kCFBooleanTrue
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
        // key size
        NSUInteger keySize = 8 * SecKeyGetBlockSize(publicKeyRef);
        
        NSString *algorithm = @"RSA";
        NSString *pkFmt = @"-----BEGIN PUBLIC KEY----- %@ -----END PUBLIC KEY-----";
        NSString *skFmt = @"-----BEGIN RSA PRIVATE KEY----- %@ -----END RSA PRIVATE KEY-----";
        NSString *pkc = [NSString stringWithFormat:pkFmt, [pkData base64Encode]];
        NSString *skc = [NSString stringWithFormat:skFmt, [skData base64Encode]];
        NSString *content = [pkc stringByAppendingString:skc];
        NSDictionary *info = @{@"algorithm": algorithm,
                               @"size" : @(keySize),
                               @"data" : content};
        SK = [[MKMRSAPrivateKey alloc] initWithAlgorithm:algorithm keyInfo:info];
    }
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    
    return SK;
}

- (BOOL)saveKeyWithCode:(NSUInteger)code {
    if (!_privateKeyRef) {
        NSAssert(false, @"_privateKeyRef cannot be empty");
        return NO;
    }
    
    NSString *label = @"net.dim.rsa.private";
    NSString *tag = [NSString stringWithFormat:@"%010lu", code];
    
    NSDictionary *query = @{(id)kSecClass: (id)kSecClassKey,
                            (id)kSecAttrApplicationLabel: [label data],
                            (id)kSecAttrApplicationTag: [tag data],
                            (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                            (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                            (id)kSecAttrSynchronizable: (id)kCFBooleanTrue,
                            
                            (id)kSecMatchLimit: (id)kSecMatchLimitOne,
                            (id)kSecReturnRef: (id)kCFBooleanTrue
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
