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

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;

@end

@interface MKMAccount ()

@property (strong, nonatomic) MKMAccountProfile *profile;
@property (nonatomic) MKMAccountStatus status;

@property (strong, nonatomic) MKMPublicKey *publicKey;

@end

@implementation MKMAccount

- (instancetype)init {
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    MKMMeta *meta = [[MKMEntityManager sharedInstance] metaForID:ID];
    self = [self initWithID:ID meta:meta];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMAccountProfile alloc] init];
        _status = MKMAccountStatusInitialized;
        _publicKey = meta.key;
    }
    return self;
}

- (id)copy {
    MKMAccount *account = [super copy];
    if (account) {
        account.profile = _profile;
        account.status = _status;
        account.publicKey = _publicKey;
    }
    return account;
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
