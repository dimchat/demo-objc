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

@property (strong, nonatomic, nullable) DIMConnection *currentConnection;
@property (weak, nonatomic) id<DIMConnector> connector;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

- (BOOL)connectTo:(const DIMStation *)station;
- (BOOL)reconnect;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
