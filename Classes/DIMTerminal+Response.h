//
//  DIMTerminal+Response.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *kNotificationName_ProfileUpdated = @"ProfileUpdated";
static NSString *kNotificationName_OnlineUsersUpdated = @"OnlineUsersUpdated";
static NSString *kNotificationName_SearchUsersUpdated = @"SearchUsersUpdated";

@interface DIMTerminal (Response)

- (void)processHandshakeMessageContent:(DIMMessageContent *)content;

- (void)processMetaMessageContent:(DIMMessageContent *)content;
- (void)processProfileMessageContent:(DIMMessageContent *)content;

- (void)processOnlineUsersMessageContent:(DIMMessageContent *)content;
- (void)processSearchUsersMessageContent:(DIMMessageContent *)content;

@end

NS_ASSUME_NONNULL_END
