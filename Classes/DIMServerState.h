//
//  DIMServerState.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/7.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <FiniteStateMachine/FiniteStateMachine.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *kDIMServerState_Default;     // (re)set user
extern NSString *kDIMServerState_Connecting;  // connecting to server
extern NSString *kDIMServerState_Connected;   // success to connect server
extern NSString *kDIMServerState_Handshaking; // trying to login
extern NSString *kDIMServerState_Running;     // user login
extern NSString *kDIMServerState_Error;       // failed to connect
extern NSString *kDIMServerState_Stopped;     // disconnected

@class DIMServer;

@interface DIMServerStateMachine : FSMMachine

@property (weak, nonatomic) DIMServer *server;
@property (strong, nonatomic, nullable) NSString *session;

@end

NS_ASSUME_NONNULL_END
