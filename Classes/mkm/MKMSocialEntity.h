//
//  MKMSocialEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"
#import "MKMProfile.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;

@interface MKMSocialEntity : MKMEntity {
    
    // parse the history to update profiles
    MKMID *_founder;
    MKMID *_owner;
    
    // parse the history to update members
    NSMutableArray<const MKMID *> *_members;
    
    // profiles
    MKMSocialEntityProfile *_profile;
}

@property (readonly, strong, nonatomic) MKMID *founder;
@property (readonly, strong, nonatomic) MKMID *owner;

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *members;

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

// special fields in profile
@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *logo; // URL

- (void)updateProfile:(const MKMSocialEntityProfile *)profile;

@end

NS_ASSUME_NONNULL_END
