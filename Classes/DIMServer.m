//
//  DIMServer.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "NSNotificationCenter+Extension.h"

#import "DIMServerState.h"

#import "DIMServer.h"

const NSString *kNotificationName_ServerStateChanged = @"ServerStateChanged";

@interface DIMServer ()

@property (strong, nonatomic) DIMServerStateMachine *fsm;
@property (strong, nonatomic) id<SGStar> star;

@end

@implementation DIMServer

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID {
    if (self = [super initWithID:ID]) {
        _currentUser = nil;
        
        _fsm = [[DIMServerStateMachine alloc] init];
        _fsm.server = self;
        _fsm.delegate = self;
        _star = nil;
    }
    return self;
}

- (void)setCurrentUser:(DIMUser *)newUser {
    if (![_currentUser isEqual:newUser]) {
        _currentUser = newUser;
        
        // update keystore
        [DIMKeyStore sharedInstance].currentUser = newUser;
        
        // switch state for re-login
        _fsm.session = nil;
    }
}

- (void)handshakeWithSession:(nullable NSString *)session {
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    
    DIMHandshakeCommand *cmd;
    cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:session];
    
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:cmd
                                               sender:_currentUser.ID
                                             receiver:_ID
                                                 time:nil];
    DIMReliableMessage *rMsg;
    rMsg = [trans encryptAndSignMessage:iMsg];
    
    // first handshake?
    if (cmd.state == DIMHandshake_Start) {
        rMsg.meta = DIMMetaForID(_currentUser.ID);
    }
    
    DIMTransceiverCallback callback;
    callback = ^(const DKDReliableMessage * rMsg, const NSError * _Nullable error) {
        if (error) {
            NSLog(@"send handshake command error: %@", error);
        } else {
            NSLog(@"sent handshake command: %@ -> %@", cmd, rMsg);
        }
    };
    
    // TODO: insert the task in front of the sending queue
    [trans sendReliableMessage:rMsg callback:callback];
}

- (void)handshakeAccepted:(BOOL)success session:(nullable NSString *)session {
    if (![_fsm.currentState.name isEqualToString:kDIMServerState_Handshaking]) {
        // FIXME: sometimes the current state will be not 'handshaking' here
        //NSAssert(false, @"state error: %@", _fsm.currentState.name);
        return ;
    }
    if (success) {
        NSLog(@"handshake success: %@", session);
        _fsm.session = session;
    } else {
        NSLog(@"handshake failed");
        // TODO: prompt to handshake again
    }
}

#pragma mark -

- (void)startWithOptions:(NSDictionary *)launchOptions {
    
    [_fsm start];
    
    [DIMTransceiver sharedInstance].delegate = self;
    
    _star = [[MGMars alloc] initWithMessageHandler:self];
    [_star launchWithOptions:launchOptions];
    
    [self performSelectorInBackground:@selector(run) withObject:nil];
}

- (void)end {
    NSAssert(_star, @"star not found");
    [_star terminate];
    [_fsm stop];
}

- (void)pause {
    NSAssert(_star, @"star not found");
    [_star enterBackground];
    [_fsm pause];
}

- (void)resume {
    NSAssert(_star, @"star not found");
    [_star enterForeground];
    [_fsm resume];
}

- (void)run {
    FSMState *state;
    NSString *name;
    while (![name isEqualToString:kDIMServerState_Stopped]) {
        sleep(1);
        [_fsm tick];
        state = _fsm.currentState;
        name = state.name;
    }
}

#pragma mark SGStarDelegate

- (NSInteger)star:(id<SGStar>)star onReceive:(const NSData *)responseData {
    NSLog(@"response data len: %ld", responseData.length);
    NSAssert(_delegate, @"station delegate not set");
    [_delegate station:self didReceivePackage:responseData];
    return 0;
}

- (void)star:(id<SGStar>)star onConnectionStatusChanged:(SGStarStatus)status {
    NSLog(@"DIM Server: Star status changed to %d", status);
    [_fsm tick];
}

#pragma mark DKDTransceiverDelegate

- (BOOL)sendPackage:(const NSData *)data completionHandler:(nullable DIMTransceiverCompletionHandler)handler {
    NSLog(@"sending data len: %ld", data.length);
    NSAssert(_star, @"star not found");
    NSInteger res = [_star send:data];
    
    if (handler) {
        NSError *error;
        if (res < 0) {
            error = [[NSError alloc] initWithDomain:NSNetServicesErrorDomain
                                               code:res
                                           userInfo:nil];
        } else {
            error = nil;
        }
        handler(error);
    }
    
    return res == 0;
}

#pragma mark - FSMDelegate

- (void)machine:(FSMMachine *)machine enterState:(FSMState *)state {
    NSDictionary *info = @{@"state": state.name};
    const NSString *name = kNotificationName_ServerStateChanged;
    [NSNotificationCenter postNotificationName:name
                                        object:self
                                      userInfo:info];
}

- (void)machine:(FSMMachine *)machine exitState:(FSMState *)state {
    //
}

@end
