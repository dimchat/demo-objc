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
    if (![self matchPrivateKey:privateKey]) {
        NSAssert(false, @"private key not match");
        return ;
    }
    if (![_privateKey isEqual:privateKey]) {
        _privateKey = [privateKey copy];
    }
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
