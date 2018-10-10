//
//  MKMSocialEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;

@interface MKMSocialEntity : MKMEntity {
    
    // parse the history to update profiles
    const MKMID *_founder;
    const MKMID *_owner;
    const NSString *_name;
    
    // parse the history to update members
    NSMutableArray<const MKMID *> *_members;
}

@property (readonly, strong, nonatomic) const MKMID *founder;
@property (readonly, strong, nonatomic) const MKMID *owner;

@property (readonly, strong, nonatomic) const NSArray *members;

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

- (BOOL)isFounder:(const MKMID *)ID;
- (BOOL)isOwner:(const MKMID *)ID;
/**
 *  DON'T call these methods to update social entity directly,
 *  use runHistory:/runHistoryRecord: to change members
 */
//- (void)addMember:(const MKMID *)ID;
//- (void)removeMember:(const MKMID *)ID;
- (BOOL)isMember:(const MKMID *)ID;

// +create(founder)
// -setName(name)
// -abdicate(member, owner)
// -invite(user, admin)
// -expel(member, admin)
// -join(user)
// -quit(member)

@end

@interface MKMSocialEntity (Profile)

@property (readonly, strong, nonatomic) const NSString *name;

@end

NS_ASSUME_NONNULL_END
