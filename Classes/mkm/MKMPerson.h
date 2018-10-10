//
//  MKMPerson.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"
#import "MKMProfile.h"

NS_ASSUME_NONNULL_BEGIN

#define MKM_IMMORTAL_HULK_ID @"hulk@4bejC3UratNYGoRagiw8Lj9xJrx8bq6nnN"
#define MKM_MONKEY_KING_ID   @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi"

@class MKMPublicKey;
@class MKMPrivateKey;

typedef NS_ENUM(SInt32, MKMPersonStatus) {
    MKMPersonStatusInitialized = 0,
    MKMPersonStatusRegistered = 1,
    MKMPersonStatusDead = -1,
};

@interface MKMPerson : MKMEntity {
    
    // profiles
    MKMPersonProfile *_profile;
    
    // parse the history to update status
    MKMPersonStatus _status;
}

@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;
@property (readonly, nonatomic) MKMPersonStatus status;

@property (readonly, strong, nonatomic) const MKMPersonProfile *profile;

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

@end

@interface MKMPerson (Profile)

// special fields in profile
@property (readonly, strong, nonatomic) const NSString *name;
@property (readonly, nonatomic) MKMGender gender;
@property (readonly, strong, nonatomic) const NSString *avatar; // URL

@end

NS_ASSUME_NONNULL_END
