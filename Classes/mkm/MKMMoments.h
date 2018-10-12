//
//  MKMMoments.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"
#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMMoments : MKMSocialEntity {
    
    NSMutableArray<const MKMID *> *_exclusions;
    NSMutableArray<const MKMID *> *_ignores;
}

// Don't Share My Moments
@property (readonly, strong, nonatomic) NSArray<const MKMID *> *exclusions;
// Hide User's Moments
@property (readonly, strong, nonatomic) NSArray<const MKMID *> *ignores;

/**
 Get account ID who owns this moments
 */
@property (readonly, nonatomic) MKMID *account;

// -exclude(member)
// -ignore(member)

// -post(content)
// -like(moment)
// -reply(moment, comment)

@end

#pragma mark - Connection between Account & Moments

@interface MKMAccount (Moments)

/**
 Get moments ID owns by this account
 */
@property (readonly, nonatomic) MKMID *moments;

@end

NS_ASSUME_NONNULL_END
