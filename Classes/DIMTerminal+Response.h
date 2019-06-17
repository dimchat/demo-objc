//
//  DIMTerminal+Response.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSString *kNotificationName_ProfileUpdated;
extern const NSString *kNotificationName_OnlineUsersUpdated;
extern const NSString *kNotificationName_SearchUsersUpdated;

@interface DIMTerminal (Response)

- (void)processHandshakeCommand:(DIMCommand *)cmd;

- (void)processMetaCommand:(DIMCommand *)cmd;
- (void)processProfileCommand:(DIMCommand *)cmd;

- (void)processOnlineUsersCommand:(DIMCommand *)cmd;
- (void)processSearchUsersCommand:(DIMCommand *)cmd;

@end

NS_ASSUME_NONNULL_END
