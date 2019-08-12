//
//  DIMServer.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/StarGate.h>
#import <DIMCore/DIMCore.h>

#import "DIMServerState.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNotificationName_ServerStateChanged;

@interface DIMServer : DIMStation <DIMTransceiverDelegate, SGStarDelegate, FSMDelegate> {
    
    DIMLocalUser *_currentUser;
    
    DIMServerStateMachine *_fsm;
}

@property (strong, nonatomic) DIMLocalUser *currentUser;

@property (readonly, strong, nonatomic) id<SGStar> star;

- (void)handshakeWithSession:(nullable NSString *)session;
- (void)handshakeAccepted:(BOOL)success session:(nullable NSString *)session;

#pragma mark -

- (void)startWithOptions:(nullable NSDictionary *)launchOptions;
- (void)end;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
