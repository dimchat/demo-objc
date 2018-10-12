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

#import "MKMProfile.h"
#import "MKMFacebook.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (strong, nonatomic) MKMAccountProfile *profile;
@property (nonatomic) MKMAccountStatus status;

@property (strong, nonatomic) MKMPublicKey *publicKey;

@end

@implementation MKMAccount

- (instancetype)init {
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMMeta *meta = [em metaWithID:ID];
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMAccountProfile alloc] init];
        _status = MKMAccountStatusInitialized;
    }
    return self;
}

- (id)copy {
    MKMAccount *account = [super copy];
    if (account) {
        account.profile = _profile;
        account.status = _status;
    }
    return account;
}

- (MKMPublicKey *)publicKey {
    if (!_publicKey) {
        MKMEntityManager *em = [MKMEntityManager sharedManager];
        MKMMeta *meta = [em metaWithID:_ID];
        _publicKey = [MKMPublicKey keyWithKey:meta.key];
    }
    return _publicKey;
}

- (MKMAccountProfile *)profile {
    if (!_profile || _profile.allKeys.count == 0) {
        MKMFacebook *facebook = [MKMFacebook sharedInstance];
        MKMProfile *prof = [facebook profileWithID:_ID];
        _profile = [MKMAccountProfile profileWithProfile:prof];
    }
    return _profile;
}

@end

@implementation MKMAccount (Profile)

- (NSString *)name {
    NSString *str = self.profile.name;
    if (!str) {
        str = _ID.name;
    }
    return str;
}

- (MKMGender)gender {
    return self.profile.gender;
}

- (NSString *)avatar {
    return self.profile.avatar;
}

@end
