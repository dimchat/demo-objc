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
        user.privateKey = _privateKey;
        user.contacts = _contacts;
    }
    return user;
}

- (MKMPrivateKey *)privateKey {
    if (!_privateKey) {
        // try to load private key from the keychain
        MKMPrivateKey *SK = [MKMPrivateKey loadKeyWithIdentifier:_ID.address];
        _privateKey = [SK copy];
    }
    NSAssert([self.publicKey isMatch:_privateKey], @"keys not match");
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

@end
