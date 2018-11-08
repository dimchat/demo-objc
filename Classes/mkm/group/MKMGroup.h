//
//  MKMGroup.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroup : MKMEntity {
    
    // parse the history to update profiles
    MKMID *_founder;
    MKMID *_owner;
    
    // parse the history to update members
    NSMutableArray<const MKMID *> *_members;
}

@property (readonly, strong, nonatomic) MKMID *founder;
@property (strong, nonatomic) MKMID *owner;

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *members;

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

#pragma mark - Group Delegate

@protocol MKMGroupDataSource <NSObject>

- (MKMID *)founderForGroupID:(const MKMID *)ID;

@optional
- (MKMID *)ownerForGroupID:(const MKMID *)ID;

@end

@protocol MKMGroupDelegate <NSObject>

- (MKMGroup *)groupWithID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
