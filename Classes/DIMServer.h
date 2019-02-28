//
//  DIMServer.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/StarGate.h>
#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMServerState) {
    DIMServerState_Init,         // (re)set user, (re)connect
    DIMServerState_Connecting,   // connecting to server
    DIMServerState_Connected,    // success to connect server
    DIMServerState_Error,        // failed to connect
    DIMServerState_ShakingHands, // user not login
    DIMServerState_Running,      // user login, sending msg
    DIMServerState_Stopped,      // disconnected
};

@interface DIMServer : DIMStation <SGStarDelegate, DIMTransceiverDelegate> {
    
    DIMUser *_currentUser;
    
    DIMServerState _state;
}

@property (strong, nonatomic) DIMUser *currentUser;

@property (readonly, nonatomic) DIMServerState state;
@property (readonly, strong, nonatomic) id<SGStar> star;

- (void)handshakeWithSession:(nullable NSString *)session;
- (void)handshakeAccepted:(BOOL)success;

#pragma mark -

- (void)startWithOptions:(nullable NSDictionary *)launchOptions;
- (void)end;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
