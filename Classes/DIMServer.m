//
//  DIMServer.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "NSObject+Extension.h"
#import "NSNotificationCenter+Extension.h"

#import "DIMFacebook.h"
#import "DIMMessenger.h"

#import "DIMFileServer.h"

#import "DIMServerState.h"

#import "DIMServer.h"

@interface PackageHandler : NSObject

@property (strong, nonatomic) NSData *data;
@property (nonatomic) DIMTransceiverCompletionHandler handler;

- (instancetype)initWithData:(NSData *)data handler:(DIMTransceiverCompletionHandler)handler;

+ (id<NSCopying>)keyWithData:(NSData *)data;

@end

@implementation PackageHandler

- (instancetype)initWithData:(NSData *)data
                     handler:(DIMTransceiverCompletionHandler)handler {
    if (self = [self init]) {
        _data = data;
        _handler = handler;
    }
    return self;
}

+ (id<NSCopying>)keyWithData:(NSData *)data {
    return [data sha256];
}

@end

#pragma mark -

NSString * const kNotificationName_ServerStateChanged = @"ServerStateChanged";

@interface DIMServer () {
    
    NSMutableArray<PackageHandler *> *_waitingList;
    NSMutableDictionary<id<NSCopying>, PackageHandler *> *_sendingTable;
}

@property (strong, nonatomic) DIMServerStateMachine *fsm;
@property (strong, nonatomic) id<SGStar> star;

@end

@implementation DIMServer

/* designated initializer */
- (instancetype)initWithID:(DIMID *)ID {
    if (self = [super initWithID:ID]) {
        _currentUser = nil;
        
        _waitingList = [[NSMutableArray alloc] init];
        _sendingTable = [[NSMutableDictionary alloc] init];
        
        _fsm = [[DIMServerStateMachine alloc] init];
        _fsm.server = self;
        _fsm.delegate = self;
        _star = nil;
        
        [[DIMFacebook sharedInstance] cacheUser:self];
    }
    return self;
}

- (void)setCurrentUser:(DIMLocalUser *)newUser {
    if (![_currentUser isEqual:newUser]) {
        _currentUser = newUser;
        
        // switch state for re-login
        _fsm.session = nil;
    }
}

- (void)handshakeWithSession:(nullable NSString *)session {
    if (![_currentUser.ID isValid]) {
        NSAssert(false, @"current user error: %@", _currentUser);
        return ;
    }
    if (![_fsm.currentState.name isEqualToString:kDIMServerState_Handshaking]) {
        // FIXME: sometimes the connection state will be reset
        //NSAssert(false, @"server state error: %@", _fsm.currentState.name);
        NSLog(@"server state error: %@", _fsm.currentState.name);
        return ;
    }
    if (_star.status != SGStarStatus_Connected) {
        // FIXME: sometimes the connection will be lost while handshaking
        //NSAssert(false, @"star status error: %d", _star.status);
        NSLog(@"star status error: %d", _star.status);
        return ;
    }
    
    DIMHandshakeCommand *cmd;
    cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:session];
    NSLog(@"handshake command: %@", cmd);
    
    DIMInstantMessage *iMsg = DKDInstantMessageCreate(cmd, _currentUser.ID, _ID, nil);
    DIMReliableMessage *rMsg = [[DIMMessenger sharedInstance] encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        return ;
    }
    
    // first handshake?
    if (cmd.state == DIMHandshake_Start) {
        rMsg.meta = _currentUser.meta;
    }
    
    // send out directly
    NSData *data = [rMsg jsonData];
    [_star send:data];
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

- (void)_carryOutWaitingTasks {
    NSArray *waitingList = [_waitingList copy];
    NSLog(@"carry out %lu waiting task(s)...", waitingList.count);
    for (PackageHandler *wrapper in waitingList) {
        if ([_fsm.currentState.name isEqualToString:kDIMServerState_Running]) {
            [self sendPackage:wrapper.data completionHandler:wrapper.handler];
            [_waitingList removeObject:wrapper];
        } else {
            NSLog(@"connection lost again, waiting task(s) interrupted");
            break;
        }
        sleep(1);
    }
}

#pragma mark -

- (void)startWithOptions:(NSDictionary *)launchOptions {
    
    [_fsm start];
    
    [DIMMessenger sharedInstance].delegate = self;
    
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

- (NSInteger)star:(id<SGStar>)star onReceive:(NSData *)responseData {
    NSLog(@"response data len: %ld", responseData.length);
    NSAssert(_delegate, @"station delegate not set");
    [_delegate station:self didReceivePackage:responseData];
    return 0;
}

- (void)star:(id<SGStar>)star onConnectionStatusChanged:(SGStarStatus)status {
    NSLog(@"DIM Server: Star status changed to %d", status);
    [_fsm tick];
}

- (void)star:(id<SGStar>)star onFinishSend:(NSData *)requestData withError:(NSError *)error {
    DIMTransceiverCompletionHandler handler = NULL;
    
    id key = [PackageHandler keyWithData:requestData];
    PackageHandler *wrapper = [_sendingTable objectForKey:key];
    if (wrapper) {
        handler = wrapper.handler;
        NSAssert([wrapper.data isEqual:requestData], @"data not match, error: %@", error);
        //requestData = wrapper.data;
        [_sendingTable removeObjectForKey:key];
    }
    
    if (error == nil) {
        // send sucess
        if ([_delegate respondsToSelector:@selector(station:didSendPackage:)]) {
            [_delegate station:self didSendPackage:requestData];
        }
        NSLog(@"send data package success");
    } else {
        if ([_delegate respondsToSelector:@selector(station:sendPackage:didFailWithError:)]) {
            [_delegate station:self sendPackage:requestData didFailWithError:error];
        }
        NSLog(@"send data package failed: %@", error);
    }
    
    if (handler) {
        // tell the handler to do the resending job
        handler(error);
    }
}

#pragma mark DKDTransceiverDelegate

- (BOOL)sendPackage:(NSData *)data completionHandler:(nullable DIMTransceiverCompletionHandler)handler {
    NSLog(@"sending data len: %ld", data.length);
    NSAssert(_star, @"star not found");
    
    PackageHandler *wrapper;
    wrapper = [[PackageHandler alloc] initWithData:data handler:handler];
    
    if (![_fsm.currentState.name isEqualToString:kDIMServerState_Running]) {
        NSLog(@"current server's state: %@, puth the request data to waiting queue", _fsm.currentState.name);
        [_waitingList addObject:wrapper];
        return YES;
    }
    
    NSInteger res = [_star send:data];
    
    if (handler) {
        id key = [PackageHandler keyWithData:data];
        [_sendingTable setObject:wrapper forKey:key];
    }
    
    return res == 0;
}

- (nullable NSURL *)uploadEncryptedFileData:(NSData *)CT forMessage:(DIMInstantMessage *)iMsg {
    DIMID *sender = DIMIDWithString(iMsg.envelope.sender);
    DIMFileContent *content = (DIMFileContent *)iMsg.content;
    NSString *filename = content.filename;
    
    DIMFileServer *ftp = [DIMFileServer sharedInstance];
    return [ftp uploadEncryptedData:CT filename:filename sender:sender];
}

- (nullable NSData *)downloadEncryptedFileData:(NSURL *)url forMessage:(DIMInstantMessage *)iMsg {
    
    DIMFileServer *ftp = [DIMFileServer sharedInstance];
    return [ftp downloadEncryptedDataFromURL:url];
}

#pragma mark - FSMDelegate

- (void)machine:(FSMMachine *)machine enterState:(FSMState *)state {
    NSDictionary *info = @{@"state": state.name};
    NSString *name = kNotificationName_ServerStateChanged;
    [NSNotificationCenter postNotificationName:name
                                        object:self
                                      userInfo:info];
    
    if ([state.name isEqualToString:kDIMServerState_Handshaking]) {
        // start handshake
        [self handshakeWithSession:_fsm.session];
    } else if ([state.name isEqualToString:kDIMServerState_Running]) {
        // send all packages waiting
        void (^block)(void) = ^{
            [self _carryOutWaitingTasks];
        };
        [NSObject performBlock:block afterDelay:1.0];
    }
}

- (void)machine:(FSMMachine *)machine exitState:(FSMState *)state {
    //
}

@end
