//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMEntityManager.h"

#import "MKMHistory.h"
#import "MKMEntity+History.h"
#import "MKMAccountHistoryDelegate.h"

#import "MKMProfile.h"
#import "MKMFacebook.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@property (strong, nonatomic) MKMAccountProfile *profile;

@end

@implementation MKMAccount

+ (instancetype)accountWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"addr error");
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMMeta *meta = [em metaWithID:ID];
    MKMHistory *history = [em historyWithID:ID];
    MKMAccount *account = [[self alloc] initWithID:ID meta:meta];
    if (account) {
        MKMAccountHistoryDelegate *delegate;
        delegate = [[MKMAccountHistoryDelegate alloc] init];
        account.historyDelegate = delegate;
        NSUInteger count = [account runHistory:history];
        NSAssert(count == history.count, @"history error");
    }
    return account;
}

- (instancetype)init {
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    self = [self initWithID:ID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (!ID) {
        ID = [MKMID IDWithID:MKM_MONKEY_KING_ID];
        NSAssert(!meta, @"unexpected meta: %@", meta);
    }
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMAccountProfile alloc] init];
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
    return _ID.publicKey;
}

- (MKMAccountProfile *)profile {
    if (!_profile || _profile.allKeys.count == 0) {
        MKMFacebook *facebook = [MKMFacebook sharedInstance];
        id prof = [facebook profileWithID:_ID];
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
