//
//  MKMAccount.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"
#import "MKMProfile.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;

typedef NS_ENUM(SInt32, MKMAccountStatus) {
    MKMAccountStatusInitialized = 0,
    MKMAccountStatusRegistered = 1,
    MKMAccountStatusDead = -1,
};

@interface MKMAccount : MKMEntity {
    
    // public key
    MKMPublicKey *_publicKey;
    
    // account status (parse history to update)
    MKMAccountStatus _status;

    // profiles
    MKMAccountProfile *_profile;
}

@property (readonly, strong, nonatomic) MKMPublicKey *publicKey;

@property (readonly, nonatomic) MKMAccountStatus status;

- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK
NS_DESIGNATED_INITIALIZER;

@end

@interface MKMAccount (Profile)

// special fields in profile
@property (nonatomic) MKMGender gender;
@property (strong, nonatomic) NSString *avatar; // URL

- (void)updateProfile:(const MKMAccountProfile *)profile;

@end

NS_ASSUME_NONNULL_END
