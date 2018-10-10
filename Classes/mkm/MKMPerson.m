//
//  MKMPerson.m
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
#import "MKMFacebook.h"

#import "MKMPerson.h"

@interface MKMPerson ()

@property (nonatomic) MKMPersonStatus status;

@property (strong, nonatomic) const MKMPersonProfile *profile;

@end

@implementation MKMPerson

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
        _profile = [[MKMPersonProfile alloc] init];
    }
    return self;
}

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

- (const MKMPersonProfile *)profile {
    if (!_profile || _profile.allKeys.count == 0) {
        MKMFacebook *facebook = [MKMFacebook sharedInstance];
        id prof = [facebook profileWithID:_ID];
        _profile = [MKMPersonProfile profileWithProfile:prof];
    }
    return _profile;
}

@end

@implementation MKMPerson (Profile)

- (const NSString *)name {
    const NSString *str = self.profile.name;
    if (!str) {
        str = _ID.name;
    }
    return str;
}

- (MKMGender)gender {
    return self.profile.gender;
}

- (const NSString *)avatar {
    return self.profile.avatar;
}

@end
