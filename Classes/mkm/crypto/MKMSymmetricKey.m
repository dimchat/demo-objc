//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

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
        keyInfo = _storeDictionary;
        
        // passphrase
        NSString *PW = [keyInfo objectForKey:@"passphrase"];
        if (!PW) {
            PW = [keyInfo objectForKey:@"password"];
        }
        _passphrase = PW;
    }
    
    return self;
}

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
