//
//  MKMGroup.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroup : MKMSocialEntity {
    
    const NSMutableArray *_administrators;
}

@property (readonly, strong, nonatomic) const NSArray *administrators;

/**
 *  DON'T call these methods to update group directly,
 *  use runHistory:/runHistoryRecord: to change administrators
 */
//- (void)addAdmin:(const MKMID *)ID;
//- (void)removeAdmin:(const MKMID *)ID;
- (BOOL)isAdmin:(const MKMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

NS_ASSUME_NONNULL_END
