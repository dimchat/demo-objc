//
//  MKMContact.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMMemo;

@interface MKMContact : MKMAccount {
    
    const MKMMemo *_memo; // same keys to the profile
}

@property (readonly, strong, nonatomic) const NSString *name;
@property (readonly, nonatomic) const MKMGender gender;
@property (readonly, strong, nonatomic) const NSString *avatar; // URL

@property (readonly, strong, nonatomic) const MKMMemo *memo;

@end

NS_ASSUME_NONNULL_END
