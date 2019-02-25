//
//  DIMTerminal.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>
#import <MarsGate/StarGate.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMTerminalState) {
    DIMTerminalState_Init,         // (re)set user, (re)connect
    DIMTerminalState_Connecting,   // connecting to server
    DIMTerminalState_Connected,    // success to connect server
    DIMTerminalState_Error,        // failed to connect
    DIMTerminalState_ShakingHands, // user not login
    DIMTerminalState_Running,      // user login, sending msg
    DIMTerminalState_Stopped,      // disconnected
};

@interface DIMTerminal : NSObject <DIMTransceiverDelegate, SGStarDelegate> {
    
    NSMutableArray<DIMUser *> *_users;
    DIMUser *_currentUser;
    
    DIMStation *_currentStation;
    
    DIMTerminalState _state;
    NSString *_session;
}

@property (readonly, nonatomic) NSString *userAgent;

#pragma mark - User(s)

@property (readonly, strong, nonatomic) NSArray<DIMUser *> *users;
@property (strong, nonatomic) DIMUser *currentUser;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

#pragma mark - Server

@property (strong, nonatomic) DIMStation *currentStation;

@property (nonatomic) DIMTerminalState state;
@property (strong, nonatomic) NSString *session;

@property (weak, nonatomic) id<DIMStationDelegate> delegate;

- (void)startWithOptions:(nullable NSDictionary *)launchOptions;
- (void)end;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
