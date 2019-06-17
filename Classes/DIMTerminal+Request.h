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

@interface DIMTerminal (Packing)

// pack and send message content to receiver
- (nullable DIMInstantMessage *)sendContent:(DIMContent *)content
                                         to:(const DIMID *)receiver;

// pack and send command to station
- (nullable DIMInstantMessage *)sendCommand:(DIMCommand *)cmd;

@end

@interface DIMTerminal (Request)

- (BOOL)login:(DIMUser *)user;

- (void)onHandshakeAccepted:(const NSString *)session;

- (nullable DIMInstantMessage *)postProfile:(DIMProfile *)profile
                                       meta:(nullable const DIMMeta *)meta;

- (nullable DIMInstantMessage *)queryMetaForID:(const DIMID *)ID;
- (nullable DIMInstantMessage *)queryProfileForID:(const DIMID *)ID;

- (nullable DIMInstantMessage *)queryOnlineUsers;
- (nullable DIMInstantMessage *)searchUsersWithKeywords:(const NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
