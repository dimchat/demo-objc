//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMUser.h"

@interface MKMUser ()

@property (strong, nonatomic) NSArray<const MKMID *> *contacts;

@end

@implementation MKMUser

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _contacts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)copy {
    MKMUser *user = [super copy];
    if (user) {
        user.contacts = _contacts;
        user.privateKey = _privateKey;
    }
    return user;
}

- (void)setPrivateKey:(MKMPrivateKey *)privateKey {
    if (privateKey) {
        // check the key first
        if ([self matchPrivateKey:privateKey]) {
            if (![_privateKey isEqual:privateKey]) {
                _privateKey = [privateKey copy];
                // persistent store to keychain
                [privateKey saveKeyWithIdentifier:_ID.address];
            }
        } else {
            NSAssert(false, @"private key not match");
        }
    } else {
        _privateKey = nil;
    }
}

- (MKMPrivateKey *)privateKey {
    if (!_privateKey) {
        // try to load private key from the keychain
        MKMPrivateKey *SK = [MKMPrivateKey loadKeyWithIdentifier:_ID.address];
        _privateKey = [SK copy];
    }
    return _privateKey;
}

- (BOOL)addContact:(MKMID *)ID {
    if ([_contacts containsObject:ID]) {
        // already exists
        return NO;
    }
    // add it
    [_contacts addObject:ID];
    return YES;
}

- (BOOL)containsContact:(const MKMID *)ID {
    return [_contacts containsObject:ID];
}

- (void)removeContact:(const MKMID *)ID {
    NSAssert([self containsContact:ID], @"contact not found");
    [_contacts removeObject:ID];
}

- (BOOL)matchPrivateKey:(const MKMPrivateKey *)SK {
    return [self.publicKey isMatch:SK];
}

@end
