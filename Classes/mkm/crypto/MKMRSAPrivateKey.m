//
//  MKMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
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
        
        if (data) {
            // public key data
            NSRange range = [data rangeOfString:@"PUBLIC KEY"];
            NSAssert(range.location != NSNotFound, @"PUBLIC KEY data not found");
            if (range.location != NSNotFound) {
                NSString *PK = RSAKeyDataFromNSString(data, YES);
                NSDictionary *pDict = @{@"algorithm":algorithm, @"data":PK};
                _publicKey = [[MKMPublicKey alloc] initWithAlgorithm:algorithm
                                                             keyInfo:pDict];
            }
            
            // private key data
            self.privateContent = RSAKeyDataFromNSString(data, NO);
        } else {
            // Generate key pairs
            NSDictionary * parameters;
            parameters = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                           (id)kSecAttrKeySizeInBits: @(_keySize),
                           (id)kSecPrivateKeyAttrs: @{(id)kSecAttrIsPermanent:@YES},
                           (id)kSecPublicKeyAttrs: @{(id)kSecAttrIsPermanent:@YES}
                           };

            SecKeyRef privateKeyRef, publicKeyRef;
            OSStatus status = SecKeyGeneratePair((CFDictionaryRef)parameters,
                                                 &publicKeyRef, &privateKeyRef);
            NSAssert(status == noErr && publicKeyRef != NULL && privateKeyRef != NULL,
                     @"failed to generate keys");
            
            // public key data
            NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
            if (publicKeyData) {
                NSDictionary *pDict = @{@"algorithm":algorithm,
                                        @"data":[publicKeyData base64Encode]};
                _publicKey = [[MKMPublicKey alloc] initWithAlgorithm:algorithm
                                                             keyInfo:pDict];
            }
            
            // private key data
            NSData *privateKeyData = NSDataFromSecKeyRef(privateKeyRef);
            if (privateKeyData) {
                _privateContent = [privateKeyData base64Encode];
                [_storeDictionary setObject:_privateContent forKey:@"data"];
            }
            _privateKeyRef = privateKeyRef;
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

- (const MKMPublicKey *)publicKey {
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
