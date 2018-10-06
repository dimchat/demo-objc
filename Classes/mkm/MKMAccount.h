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

@end

NS_ASSUME_NONNULL_END
