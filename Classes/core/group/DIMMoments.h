//
//  DIMMoments.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMoments : MKMMoments

+ (instancetype)momentsWithID:(const MKMID *)ID;

@end

#pragma mark - Connection between Account & Moments

@interface DIMMoments (Connection)

/**
 Get account ID who owns this moments
 */
@property (readonly, nonatomic) MKMID *account;

@end

@interface MKMAccount (Connection)

/**
 Get moments ID owns by this account
 */
@property (readonly, nonatomic) MKMID *moments;

@end

NS_ASSUME_NONNULL_END
