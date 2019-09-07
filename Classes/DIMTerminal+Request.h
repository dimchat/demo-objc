//
//  DIMTerminal+Request.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNotificationName_MessageSent;
extern NSString * const kNotificationName_SendMessageFailed;

@interface DIMTerminal (Packing)

// pack and send message content to receiver
- (nullable DIMInstantMessage *)sendContent:(DIMContent *)content
                                         to:(DIMID *)receiver;

// pack and send command to station
- (nullable DIMInstantMessage *)sendCommand:(DIMCommand *)cmd;

@end

@interface DIMTerminal (Request)

- (BOOL)login:(DIMLocalUser *)user;

- (void)onHandshakeAccepted:(NSString *)session;

- (nullable DIMInstantMessage *)postProfile:(DIMProfile *)profile;

- (nullable DIMInstantMessage *)queryMetaForID:(DIMID *)ID;
- (nullable DIMInstantMessage *)queryProfileForID:(DIMID *)ID;

- (nullable DIMInstantMessage *)queryOnlineUsers;
- (nullable DIMInstantMessage *)searchUsersWithKeywords:(NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
