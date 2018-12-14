//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

@interface MKMSymmetricKey ()

@property (strong, nonatomic) NSData *passphrase;

@end

@implementation MKMSymmetricKey

- (instancetype)init {
    self = [self initWithAlgorithm:SCAlgorithmAES];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if ([self isMemberOfClass:[MKMSymmetricKey class]]) {
        // create instance by subclass with algorithm
        NSString *algorithm = [keyInfo objectForKey:@"algorithm"];
        if ([algorithm isEqualToString:SCAlgorithmAES]) {
            self = [[MKMAESKey alloc] initWithDictionary:keyInfo];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else if (self = [super initWithDictionary:keyInfo]) {
        // lazy
        _passphrase = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMSymmetricKey *key = [super copyWithZone:zone];
    if (key) {
        key.passphrase = _passphrase;
    }
    return key;
}

- (NSData *)passphrase {
    while (!_passphrase) {
        NSString *PW;
        
        // passphrase
        PW = [_storeDictionary objectForKey:@"passphrase"];
        if (PW) {
            _passphrase = [PW base64Decode];
            break;
        }
        
        // password
        PW = [_storeDictionary objectForKey:@"password"];
        if (PW) {
            _passphrase = [PW base64Decode];
            break;
        }
        
        // random password
        unsigned char buf[32];
        arc4random_buf(buf, sizeof(buf));
        _passphrase = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
        PW = [_passphrase base64Encode];
        [_storeDictionary setObject:PW forKey:@"passphrase"];
        break;
    }
    return _passphrase;
}

#pragma mark - Protocol

- (NSData *)decrypt:(const NSData *)ciphertext {
    // implements in subclass
    return nil;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    // implements in subclass
    return nil;
}

@end

@implementation MKMSymmetricKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMSymmetricKey *PW = nil;
    
    // try AES
    PW = [MKMAESKey loadKeyWithIdentifier:identifier];
    if (PW) {
        return PW;
    }
    
    // key not found
    return PW;
}

@end
