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

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    if ([self isMemberOfClass:[MKMSymmetricKey class]]) {
        // create instance with algorithm
        if ([algorithm isEqualToString:SCAlgorithmAES]) {
            self = [[MKMAESKey alloc] initWithAlgorithm:algorithm keyInfo:info];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else {
        NSAssert([[self class] isSubclassOfClass:[MKMSymmetricKey class]], @"error");
        // subclass
        self = [super initWithAlgorithm:algorithm keyInfo:info];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        NSString *PW = [dict objectForKey:@"passphrase"];
        if (!PW) {
            PW = [dict objectForKey:@"password"];
        }
        NSAssert(PW, @"key data error: %@", dict);
        _passphrase = [PW copy];
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
