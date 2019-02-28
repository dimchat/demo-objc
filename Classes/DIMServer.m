//
//  DIMServer.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "DIMServer.h"

@interface DIMServer ()

@property (strong, nonatomic) id<SGStar> star;

@end

@implementation DIMServer

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        _currentUser = nil;
        
        _state = DIMServerState_Init;
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
        _state = DIMServerState_Init;
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
        rMsg.meta = MKMMetaForID(_currentUser.ID);
    }
    
    DKDTransceiverCallback callback;
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

- (void)handshakeAccepted:(BOOL)success {
    NSAssert(_state == DIMServerState_ShakingHands, @"state error");
    if (success) {
        NSLog(@"handshake success");
        _state = DIMServerState_Running;
    } else {
        NSLog(@"handshake failed");
        // TODO: prompt to handshake again
    }
}

#pragma mark -

- (void)startWithOptions:(NSDictionary *)launchOptions {
    
    _state = DIMServerState_Init;
    
    [DIMTransceiver sharedInstance].delegate = self;
    
    _star = [[MGMars alloc] initWithMessageHandler:self];
    [_star launchWithOptions:launchOptions];
    
    [self performSelectorInBackground:@selector(run) withObject:nil];
}

- (void)end {
    NSAssert(_star, @"star not found");
    [_star terminate];
    _state = DIMServerState_Stopped;
}

- (void)pause {
    NSAssert(_star, @"star not found");
    [_star enterBackground];
}

- (void)resume {
    NSAssert(_star, @"star not found");
    [_star enterForeground];
}

- (void)run {
    while (_state != DIMServerState_Stopped) {
        
        switch (_state) {
                
            case DIMServerState_Init: {
                // check user login
                if (_currentUser) {
                    _state = DIMServerState_Connecting;
                } else {
                    // waiting for new user login
                    sleep(1);
                }
            }
                break;
                
            case DIMServerState_Connecting: {
                if ([_star isConnected]) {
                    _state = DIMServerState_Connected;
                } else {
                    // waiting for long connection
                    sleep(1);
                }
            }
                break;
                
            case DIMServerState_Connected: {
                if (_currentUser) {
                    _state = DIMServerState_ShakingHands;
                    // shake hands with current station
                    [self handshakeWithSession:nil];
                } else {
                    // waiting for new user login
                    sleep(1);
                }
            }
                break;
                
            case DIMServerState_ShakingHands: {
                // waiting for handshaking
                sleep(1);
            }
                break;
                
            case DIMServerState_Running: {
                // sending or receiving messages
                sleep(1);
            }
                break;
                
            case DIMServerState_Error: {
                // reset for next connection
                NSLog(@"DIM Server error");
                _state = DIMServerState_Init;
            }
                break;
                
            case DIMServerState_Stopped: {
                // exit
                NSLog(@"DIM Server stopped");
            }
                break;
                
            default:
                break;
                
        } /* EOF switch (_state) */
        
    } /* EOF while (_state != DIMServerState_Stopped) */
}

#pragma mark SGStarDelegate

- (NSInteger)star:(id<SGStar>)star onReceive:(const NSData *)responseData {
    NSLog(@"response data len: %ld", responseData.length);
    NSAssert(_delegate, @"station delegate not set");
    [_delegate station:self didReceivePackage:responseData];
    return 0;
}

- (void)star:(id<SGStar>)star onConnectionStatusChanged:(SGStarStatus)status {
    NSLog(@"connection status changed: %d", status);
    
    switch (status) {
        case SGStarStatus_Init: {
            NSLog(@"Mars: connection init");
        }
            break;
            
        case SGStarStatus_Connecting: {
            NSLog(@"Mars: connecting server");
        }
            break;
            
        case SGStarStatus_Connected: {
            NSLog(@"Mars: server connected");
        }
            break;
            
        case SGStarStatus_Error: {
            NSLog(@"Mars: connection error");
            _state = DIMServerState_Error;
        }
            break;
            
        case SGStarStatus_Unknown: {
            NSLog(@"Mars: status unknown");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark DKDTransceiverDelegate

- (BOOL)sendPackage:(const NSData *)data completionHandler:(nullable DKDTransceiverCompletionHandler)handler {
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

@end
