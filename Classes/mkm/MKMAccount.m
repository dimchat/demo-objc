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

#import "MKMProfile.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccount

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

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

@end

@implementation MKMAccount (Profile)

- (NSString *)name {
    return _profile.name;
}

- (MKMGender)gender {
    return _profile.gender;
}

- (NSString *)avatar {
    return _profile.avatar;
}

@end
