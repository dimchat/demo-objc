//
//  MKMSocialEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<const MKMID *> MKMMemberListM;
typedef NSArray<const MKMID *> MKMMemberList;

@interface MKMSocialEntity : MKMEntity {
    
    // parse the history to update profiles
    MKMID *_founder;
    MKMID *_owner;
    
    // parse the history to update members
    MKMMemberListM *_members;
}

@property (readonly, strong, nonatomic) MKMID *founder;
@property (strong, nonatomic) MKMID *owner;

@property (readonly, strong, nonatomic) MKMMemberList *members;

- (instancetype)initWithID:(const MKMID *)ID
                 founderID:(const MKMID *)founderID
NS_DESIGNATED_INITIALIZER;

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

#pragma mark - Social Entity Delegate

@protocol MKMSocialEntityDataSource <NSObject>

- (MKMID *)founderForSocialEntityID:(const MKMID *)ID;

@optional
- (MKMID *)ownerForSocialEntityID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
