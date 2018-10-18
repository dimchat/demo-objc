//
//  DIMClient.h
//  DIM
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;
@class DIMConnection;

@protocol DIMConnector;

@interface DIMClient : NSObject <DIMConnectionDelegate>

@property (strong, nonatomic) DIMUser *currentUser;

@property (readonly, strong, nonatomic) DIMConnection *connection;
@property (weak, nonatomic) id<DIMConnector> connector;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

- (BOOL)connect:(const DIMStation *)station;
- (void)disconnect;

@end

#pragma mark - Message

@interface DIMClient (Message)

/**
 Send message (secured + certified) to target station
 
 @param cMsg - certified message
 @return YES on success
 */
- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg;

/**
 Save received message (secured + certified) from target station

 @param iMsg - instant message
 */
- (void)recvMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
