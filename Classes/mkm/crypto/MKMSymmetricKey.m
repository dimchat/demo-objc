//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

@interface MKMSymmetricKey ()

@property (strong, nonatomic) NSString *passphrase;

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

- (NSString *)passphrase {
    while (!_passphrase) {
        NSString *PW;
        
        // passphrase
        PW = [_storeDictionary objectForKey:@"passphrase"];
        if (PW) {
            _passphrase = PW;
            break;
        }
        
        // password
        PW = [_storeDictionary objectForKey:@"password"];
        if (PW) {
            _passphrase = PW;
            break;
        }
        
        // random password
        uint32_t n1 = arc4random();
        uint32_t n2 = arc4random();
        uint32_t n3 = arc4random();
        PW = [[NSString alloc] initWithFormat:@"%010u-%010u-%010u", n1, n2, n3];
        [_storeDictionary setObject:PW forKey:@"passphrase"];
        
        _passphrase = PW;
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
