//
//  MKMSocialEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;

@interface MKMSocialEntity : MKMEntity {
    
    // parse the history to update these fields
    const MKMID *_founder;
    const MKMID *_owner;
    const NSMutableArray *_members;
}

@property (readonly, strong, nonatomic) const MKMID *founder; // just first owner
@property (readonly, strong, nonatomic) const MKMID *owner;

@property (readonly, strong, nonatomic) const NSArray *members;

// +create(founder)
// -setName(name)
// -abdicate(member, owner)
// -invite(user, admin)
// -expel(member, admin)
// -join(user)
// -quit(member)

@end

NS_ASSUME_NONNULL_END
