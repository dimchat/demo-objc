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
#import "MKMEntityManager.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (strong, nonatomic) MKMAccountProfile *profile;

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccount

- (instancetype)init {
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    self = [self initWithID:ID];
    return self;
}

- (instancetype)initWithID:(const MKMID *)ID {
    MKMMeta *meta = MKMMetaForID(ID);
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _status = MKMAccountStatusInitialized;
        _profile = [[MKMAccountProfile alloc] init];
    }
    return self;
}

- (id)copy {
    MKMAccount *account = [super copy];
    if (account) {
        account.status = _status;
        account.profile = _profile;
    }
    return account;
}

- (MKMPublicKey *)publicKey {
    return _meta.key;
}

@end

@implementation MKMAccount (Profile)

- (NSString *)name {
    NSString *str = _profile.name;
    if (!str) {
        str = _ID.name;
    }
    return str;
}

- (MKMGender)gender {
    return _profile.gender;
}

- (NSString *)avatar {
    return _profile.avatar;
}

- (void)updateProfile:(const MKMAccountProfile *)profile {
    NSAssert([profile matchID:_ID], @"profile not match");
    // TODO: update profiles
}

@end
