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

#import "MKMUser.h"

@interface MKMUser ()

@property (strong, nonatomic) NSArray<const MKMID *> *contacts;

@end

@implementation MKMUser

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        // lazy
        _privateKey = nil;
        _contacts = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMUser *user = [super copyWithZone:zone];
    if (user) {
        user.privateKey = _privateKey;
        user.contacts = _contacts;
    }
    return user;
}

- (MKMPrivateKey *)privateKey {
    if (!_privateKey) {
        // try to load private key from the keychain
        _privateKey = [MKMPrivateKey loadKeyWithIdentifier:_ID.address];
    }
    NSAssert([_publicKey isMatch:_privateKey], @"keys not match");
    return _privateKey;
}

- (BOOL)addContact:(MKMID *)ID {
    if ([_contacts containsObject:ID]) {
        // already exists
        return NO;
    }
    if (!_contacts) {
        _contacts = [[NSMutableArray alloc] init];
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

@end
