//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "DIMTerminal+Command.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

@property (strong, nonatomic) NSMutableArray<DIMUser *> *users;

@property (strong, nonatomic) id<SGStar> star;

@end

@implementation DIMTerminal

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        _currentUser = nil;
        
        _currentStation = nil;
        _state = DIMTerminalState_Init;
        _session = nil;
        
        _delegate = nil;
        
        _star = nil;
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

#pragma mark - User(s)

- (void)setCurrentUser:(DIMUser *)newUser {
    if (![_currentUser isEqual:newUser]) {
        _currentUser = newUser;
        // add to the list of this client
        if (newUser && ![_users containsObject:newUser]) {
            [_users addObject:newUser];
        }
        
        // update keystore
        [DIMKeyStore sharedInstance].currentUser = newUser;
    }
}

- (void)addUser:(DIMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentUser) {
        _currentUser = user;
    }
}

- (void)removeUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentUser isEqual:user]) {
        _currentUser = _users.firstObject;
    }
}

#pragma mark - Server

- (void)setCurrentStation:(DIMStation *)newStation {
    if (![_currentStation isEqual:newStation]) {
        _currentStation = newStation;
        _delegate = newStation.delegate;
    }
}

- (void)startWithOptions:(NSDictionary *)launchOptions {
    
    _state = DIMTerminalState_Init;
    
    [DIMTransceiver sharedInstance].delegate = self;
    
    _star = [[MGMars alloc] initWithMessageHandler:self];
    [_star launchWithOptions:launchOptions];
    
    [self performSelectorInBackground:@selector(run) withObject:nil];
}

- (void)end {
    [_star terminate];
    _state = DIMTerminalState_Stopped;
}

- (void)pause {
    [_star enterBackground];
}

- (void)resume {
    [_star enterForeground];
}

- (void)run {
    while (_state != DIMTerminalState_Stopped) {
        
        switch (_state) {
                
            case DIMTerminalState_Init: {
                // check user login
                if (_currentUser) {
                    _state = DIMTerminalState_Connecting;
                } else {
                    // waiting for new user login
                    sleep(1);
                }
            }
                break;
            
            case DIMTerminalState_Connecting: {
                if ([_star isConnected]) {
                    _state = DIMTerminalState_Connected;
                } else {
                    // waiting for long connection
                    sleep(1);
                }
            }
                break;
                
            case DIMTerminalState_Connected: {
                if (_currentUser) {
                    _state = DIMTerminalState_ShakingHands;
                    // shake hands with current station
                    [self handshake];
                } else {
                    // waiting for new user login
                    sleep(1);
                }
            }
                break;
                
            case DIMTerminalState_ShakingHands: {
                // waiting for handshaking
                sleep(1);
            }
                break;
                
            case DIMTerminalState_Running: {
                // sending or receiving messages
                sleep(1);
            }
                break;
                
            case DIMTerminalState_Error: {
                // reset for next connection
                NSLog(@"DIM Terminal error");
                _state = DIMTerminalState_Init;
            }
                break;
                
            case DIMTerminalState_Stopped: {
                // exit
                NSLog(@"DIM Terminal stopped");
            }
                break;
                
            default:
                break;
                
        } /* EOF switch (_state) */
        
    } /* EOF while (_state != DIMTerminalState_Stopped) */
}

#pragma mark DKDTransceiverDelegate

- (BOOL)sendPackage:(const NSData *)data completionHandler:(nullable DKDTransceiverCompletionHandler)handler {
    NSLog(@"sending data len: %ld", data.length);
    // TODO: send data
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

#pragma mark SGStarDelegate

- (NSInteger)star:(id<SGStar>)star onReceive:(const NSData *)responseData {
    NSLog(@"response data len: %ld", responseData.length);
    [_delegate station:_currentStation didReceivePackage:responseData];
    return 0;
}

- (void)star:(id<SGStar>)star onConnectionStatusChanged:(SGStarStatus)status {
    NSLog(@"connection status changed: %d", status);
    
    switch (status) {
        case SGStarStatus_Init: {
            _state = DIMTerminalState_Init;
            NSLog(@"DIM Terminal: connection init");
        }
            break;
            
        case SGStarStatus_Connecting: {
            _state = DIMTerminalState_Connecting;
            NSLog(@"DIM Terminal: connecting server");
        }
            break;
            
        case SGStarStatus_Connected: {
            NSAssert(_state == DIMTerminalState_Connecting, @"state error");
            _state = DIMTerminalState_Connected;
            NSLog(@"DIM Terminal: server connected");
        }
            break;
            
        case SGStarStatus_Error: {
            _state = DIMTerminalState_Error;
            NSLog(@"DIM Terminal: connection error");
        }
            break;
            
        case SGStarStatus_Unknown: {
            NSLog(@"DIM Terminal: status unknown");
        }
            break;
            
        default:
            break;
    }
}

@end
