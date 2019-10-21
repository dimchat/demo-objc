//
//  DIMTerminal+Response.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN


extern NSString * const kNotificationName_OnlineUsersUpdated;
extern NSString * const kNotificationName_SearchUsersUpdated;

@interface DIMTerminal (Response)

- (void)processHandshakeCommand:(DIMHandshakeCommand *)cmd;
- (void)processMetaCommand:(DIMMetaCommand *)cmd;
- (void)processProfileCommand:(DIMProfileCommand *)cmd;
- (void)processOnlineUsersCommand:(DIMCommand *)cmd;
- (void)processSearchUsersCommand:(DIMCommand *)cmd;
- (void)processContactsCommand:(DIMCommand *)cmd;

- (void)addUserToContact:(NSString *)itemString;

@end

NS_ASSUME_NONNULL_END
