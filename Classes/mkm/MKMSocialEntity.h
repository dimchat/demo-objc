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
    
    const NSMutableArray *_members;
}

@property (readonly, strong, nonatomic) const NSString *name;

@property (readonly, strong, nonatomic) const MKMID *founder;
@property (readonly, strong, nonatomic) const MKMID *owner;

@property (readonly, strong, nonatomic) const NSArray *members;

- (BOOL)isFounder:(const MKMID *)ID;
- (BOOL)isOwner:(const MKMID *)ID;

- (void)addMember:(const MKMID *)ID;
- (void)removeMember:(const MKMID *)ID;
- (BOOL)isMember:(const MKMID *)ID;

// +create(founder)
// -setName(name)
// -abdicate(member, owner)
// -invite(user, admin)
// -expel(member, admin)
// -join(user)
// -quit(member)

@end

NS_ASSUME_NONNULL_END
