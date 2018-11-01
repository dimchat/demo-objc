//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMMeta.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (strong, nonatomic) MKMPublicKey *publicKey;

@property (nonatomic) MKMAccountStatus status;

@property (strong, nonatomic) MKMAccountProfile *profile;

@end

@implementation MKMAccount

- (instancetype)initWithID:(const MKMID *)ID {
    MKMPublicKey *PK = nil;
    self = [self initWithID:ID publicKey:PK];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID]) {
        // public key
        _publicKey = [PK copy];
        
        // account status
        _status = MKMAccountStatusInitialized;
        
        // profile
        _profile = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAccount *account = [super copyWithZone:zone];
    if (account) {
        account.publicKey = _publicKey;
        account.status = _status;
        account.profile = _profile;
    }
    return account;
}

@end

@implementation MKMAccount (Profile)

- (void)setName:(NSString *)name {
    if (!_profile) {
        _profile = [[MKMAccountProfile alloc] init];
    }
    _profile.name = name;
    [super setName:name];
}

- (NSString *)name {
    NSString *str = _profile.name;
    if (str) {
        return str;
    }
    return [super name];
}

- (void)setGender:(MKMGender)gender {
    if (!_profile) {
        _profile = [[MKMAccountProfile alloc] init];
    }
    _profile.gender = gender;
}

- (MKMGender)gender {
    return _profile.gender;
}

- (void)setAvatar:(NSString *)avatar {
    if (!_profile) {
        _profile = [[MKMAccountProfile alloc] init];
    }
    _profile.avatar = avatar;
}

- (NSString *)avatar {
    return _profile.avatar;
}

- (void)updateProfile:(const MKMAccountProfile *)profile {
    NSAssert([profile matchID:_ID], @"profile not match");
    if (!_profile) {
        _profile = [profile copy];
    } else {
        // TODO: update profiles
    }
}

@end
