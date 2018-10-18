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

@interface DIMClient : NSObject <DIMConnectionDelegate>

@property (strong, nonatomic) DIMUser *currentUser;

@property (strong, nonatomic) DIMConnection *currentConnection;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

- (BOOL)connect:(const DIMStation *)station;
- (BOOL)reconnect;
- (void)disconnect;

@end

#pragma mark - Message

@interface DIMClient (Message)

/**
 Send message (secured + certified) to target station
 
 @param message - certified message
 @return YES on success
 */
- (BOOL)sendMessage:(const DIMCertifiedMessage *)message;

/**
 Save received message (secured + certified) from target station

 @param message - certified message
 */
- (void)saveMessage:(const DIMCertifiedMessage *)message;

@end

NS_ASSUME_NONNULL_END
