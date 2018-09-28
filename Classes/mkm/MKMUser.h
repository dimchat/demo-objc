//
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMMale   @"male"
#define MKMFemale @"female"

typedef NS_ENUM(SInt32, MKMUserGender) {
    MKMUserGenderUnknown = 0,
    MKMUserGenderMale = 1,
    MKMUserGenderFemail = 2,
};

@interface MKMUser : MKMAccount {
    
    NSString * _names;
}

@property (readonly, strong, nonatomic) const NSString *name;
@property (nonatomic) MKMUserGender gender;

@end

NS_ASSUME_NONNULL_END
