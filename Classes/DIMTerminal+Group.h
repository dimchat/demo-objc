//
//  DIMTerminal+Group.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/9.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMClient/DIMClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMTerminal (GroupManage)

- (DIMGroup *)createGroupWithSeed:(const NSString *)seed name:(const NSString *)name members:(const NSArray<const DIMID *> *)list;

- (BOOL)updateGroupWithID:(const DIMID *)ID name:(const NSString *)name members:(const NSArray<const DIMID *> *)list;

@end

@interface DIMTerminal (GroupHistory)

// group history command
- (BOOL)processInviteMembersMessageContent:(DIMMessageContent *)content;

@end

NS_ASSUME_NONNULL_END
