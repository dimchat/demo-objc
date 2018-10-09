//
//  MKMMoments.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMMoments : MKMSocialEntity {
    
    NSMutableArray<const MKMID *> *_exclusions;
    NSMutableArray<const MKMID *> *_ignores;
}

// Don't Share My Moments
@property (readonly, strong, nonatomic) const NSArray *exclusions;
// Hide User's Moments
@property (readonly, strong, nonatomic) const NSArray *ignores;

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

// -exclude(member)
// -ignore(member)

// -post(content)
// -like(moment)
// -reply(moment, comment)

@end

NS_ASSUME_NONNULL_END
