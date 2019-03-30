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

- (nullable DIMGroup *)createGroupWithSeed:(const NSString *)seed
                                   members:(const NSArray<const DIMID *> *)list
                                   profile:(nullable const NSDictionary *)dict;

- (BOOL)updateGroupWithID:(const DIMID *)ID
                  members:(const NSArray<const DIMID *> *)list
                  profile:(nullable const DIMProfile *)profile;

@end

@interface DIMTerminal (GroupHistory)

// group history command
- (BOOL)checkGroupCommand:(DIMMessageContent *)content commander:(const DIMID *)sender;

@end

NS_ASSUME_NONNULL_END
