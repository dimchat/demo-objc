//
//  MKMGroup.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroup : MKMSocialEntity {
    
    NSMutableArray<const MKMID *> *_administrators;
}

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *administrators;

- (void)addAdmin:(const MKMID *)ID;
- (void)removeAdmin:(const MKMID *)ID;
- (BOOL)isAdmin:(const MKMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

NS_ASSUME_NONNULL_END
