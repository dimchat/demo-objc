//
//  MKMAccount.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMEntity.h"
#import "MKMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define MKM_IMMORTAL_HULK_ID @"hulk@4EvGU5ufCzn2rqQ5e2c17aabvLWNY9aEJN"
#define MKM_MONKEY_KING_ID   @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi"

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMProfile;

#define MKMMale   @"male"
#define MKMFemale @"female"

typedef NS_ENUM(SInt32, MKMGender) {
    MKMGender_Unknown = 0,
    MKMGender_Male = 1,
    MKMGender_Femail = 2,
};

typedef NS_ENUM(SInt32, MKMAccountStatus) {
    MKMAccountStatusInitialized = 0,
    MKMAccountStatusRegistered = 1,
    MKMAccountStatusDead = -1,
};

@interface MKMAccount : MKMEntity {
    
    const MKMProfile *_profile;
    
    // parse the history to update status
    MKMAccountStatus _status;
}

@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;
@property (readonly, nonatomic) MKMAccountStatus status;

@property (readonly, strong, nonatomic) const MKMProfile *profile;

// special fields in profile
@property (readonly, strong, nonatomic) const NSString *name;
@property (readonly, nonatomic) MKMGender gender;
@property (readonly, strong, nonatomic) const NSString *avatar; // URL

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

- (void)setProfile:(NSString *)string forKey:(const NSString *)key;
- (NSString *)profileForKey:(const NSString *)key;

@end

NS_ASSUME_NONNULL_END
