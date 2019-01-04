//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMBarrack.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (strong, nonatomic) MKMPublicKey *publicKey;

@end

@implementation MKMAccount

- (instancetype)initWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    self = [self initWithID:ID publicKey:PK];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error");
    if (self = [super initWithID:ID]) {
        // public key
        _publicKey = [PK copy];
        
        // account status
        _status = MKMAccountStatusInitialized;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAccount *account = [super copyWithZone:zone];
    if (account) {
        account.publicKey = _publicKey;
        account.status = _status;
    }
    return account;
}

@end
