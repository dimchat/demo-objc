//
//  MKMChatroom.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<const MKMID *> MKMAdminListM;
typedef NSArray<const MKMID *> MKMAdminList;

@interface MKMChatroom : MKMSocialEntity {
    
    MKMAdminListM *_administrators;
}

@property (readonly, strong, nonatomic) MKMAdminList *administrators;

- (void)addAdmin:(const MKMID *)ID;
- (void)removeAdmin:(const MKMID *)ID;
- (BOOL)isAdmin:(const MKMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

#pragma mark - Chatroom Delegate

@protocol MKMChatroomDelegate <NSObject>

- (MKMChatroom *)chatroomWithID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
