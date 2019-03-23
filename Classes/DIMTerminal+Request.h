//
//  DIMTerminal+Request.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSString *kNotificationName_MessageSent;
extern const NSString *kNotificationName_SendMessageFailed;

@interface DIMTerminal (Request)

- (BOOL)sendContent:(DIMMessageContent *)content to:(const DIMID *)receiver;
- (BOOL)sendMessage:(DIMInstantMessage *)msg;

// pack and send command to station
- (BOOL)sendCommand:(DIMCommand *)cmd;

#pragma mark -

- (BOOL)login:(DIMUser *)user;

- (BOOL)postProfile:(DIMProfile *)profile meta:(nullable const DIMMeta *)meta;

- (BOOL)queryMetaForID:(const DIMID *)ID;
- (BOOL)queryProfileForID:(const DIMID *)ID;

- (BOOL)queryOnlineUsers;
- (BOOL)searchUsersWithKeywords:(const NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
