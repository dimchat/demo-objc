//
//  DIMServerState.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/7.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMServer.h"

#import "DIMServerState.h"

NSString *kDIMServerState_Default     = @"default";
NSString *kDIMServerState_Connecting  = @"connecting";
NSString *kDIMServerState_Connected   = @"connected";
NSString *kDIMServerState_Handshaking = @"handshaking";
NSString *kDIMServerState_Running     = @"running";
NSString *kDIMServerState_Error       = @"error";
NSString *kDIMServerState_Stopped     = @"stopped";

@implementation DIMServerStateMachine

/* designated initializer */
- (instancetype)initWithDefaultStateName:(NSString *)name capacity:(NSUInteger)capacity {
    if (self = [super initWithDefaultStateName:name capacity:capacity]) {
        _server = nil;
        _session = nil;
    }
    return self;
}

- (instancetype)init {
    NSString *name = kDIMServerState_Default;
    if (self = [self initWithDefaultStateName:name capacity:7]) {
        // add states
        [self addState:[self defaultState]];
        [self addState:[self connectingState]];
        [self addState:[self connectedState]];
        [self addState:[self handshakingState]];
        [self addState:[self runningState]];
        [self addState:[self errorState]];
        // TODO: stopped state
    }
    return self;
}

//
//  state: Default
//
- (FSMState *)defaultState {
    NSString *name = kDIMServerState_Default;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Connecting
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        DIMUser *user = server.currentUser;
        if (!user) {
            return NO;
        }
        SGStarStatus status = server.star.status;
        if (status == SGStarStatus_Connecting ||
            status == SGStarStatus_Connected) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Connecting;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Connecting
//
- (FSMState *)connectingState {
    NSString *name = kDIMServerState_Connecting;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Connected
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        if (status == SGStarStatus_Connected) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Connected;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        if (status == SGStarStatus_Error) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Connected
//
- (FSMState *)connectedState {
    NSString *name = kDIMServerState_Connected;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Handshaking
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        DIMUser *user = server.currentUser;
        if (user) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Handshaking;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Handshaking
//
- (FSMState *)handshakingState {
    NSString *name = kDIMServerState_Handshaking;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Running
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        NSString *sess = [(DIMServerStateMachine *)machine session];
        if (sess) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Running;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        if (status == SGStarStatus_Error) {
            return YES;
        }
        
        // TODO: timeout, switch to ErrorState
        
        return NO;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Running
//
- (FSMState *)runningState {
    NSString *name = kDIMServerState_Running;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        if (status != SGStarStatus_Connected) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Default
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        NSString *sess = [(DIMServerStateMachine *)machine session];
        if (!sess) {
            // user switched
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Default;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Error
//
- (FSMState *)errorState {
    NSString *name = kDIMServerState_Error;
    FSMState *state = [[FSMState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Default
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        if (status != SGStarStatus_Error) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Default;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

@end
