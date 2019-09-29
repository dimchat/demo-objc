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
- (void)sendCommand:(DIMCommand *)cmd;

// broadcast message content to everyone@everywhere
- (void)broadcastContent:(DIMContent *)content;

@end

@interface DIMTerminal (Request)

- (BOOL)login:(DIMLocalUser *)user;

- (void)onHandshakeAccepted:(NSString *)session;

- (void)postProfile:(DIMProfile *)profile; // to station
- (void)broadcastProfile:(DIMProfile *)profile; // to all contacts

- (void)postContacts:(NSArray<DIMID *> *)contacts;
-(void)getContacts;

- (void)queryMetaForID:(DIMID *)ID;
- (void)queryProfileForID:(DIMID *)ID;

- (void)queryOnlineUsers;
- (void)searchUsersWithKeywords:(NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
