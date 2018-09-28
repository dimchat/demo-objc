//
//  MKMMoments.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMMoments : MKMSocialEntity

// Don't Share My Moments
@property (readonly, strong, nonatomic) const NSArray *exclusions;
// Hide User's Moments
@property (readonly, strong, nonatomic) const NSArray *ignores;

// -exclude(member)
// -ignore(member)

// -post(content)
// -like(moment)
// -reply(moment, comment)

@end

NS_ASSUME_NONNULL_END
