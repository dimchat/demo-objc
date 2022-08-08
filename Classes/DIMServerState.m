// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
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

@interface DIMServerState () {
    
    NSDate *_enterTime;
}

@end

@implementation DIMServerState

- (instancetype)initWithName:(NSString *)name {
    if (self = [super initWithName:name]) {
        _enterTime = nil;
    }
    return self;
}

- (nullable NSDate *)enterTime {
    return _enterTime;
}

- (void)onEnter:(FSMMachine *)machine {
    [super onEnter:machine];
    _enterTime = [[NSDate alloc] init];
}

- (void)onExit:(FSMMachine *)machine {
    _enterTime = nil;
    [super onExit:machine];
}

@end

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
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Connecting
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        id<DIMUser> user = server.currentUser;
        if (!user) {
            return NO;
        }
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Connecting || status == SGStarStatus_Connected;
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
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Connected
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Connected;
    };
    name = kDIMServerState_Connected;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Error;
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
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Handshaking
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        id<DIMUser> user = server.currentUser;
        if (user) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Handshaking;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Error;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Handshaking
//
- (FSMState *)handshakingState {
    NSString *name = kDIMServerState_Handshaking;
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Running
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        // when current user changed, the server will clear this session, so
        // if it's set again, it means handshake accepted
        NSString *sess = [(DIMServerStateMachine *)machine session];
        if (sess) {
            return YES;
        }
        return NO;
    };
    name = kDIMServerState_Running;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    // target state: Connected
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServerState *state = [(DIMServerStateMachine *)machine currentState];
        NSDate *enterTime = state.enterTime;
        if (!enterTime) {
            // not enter yet
            return NO;
        }
        NSTimeInterval expired = [enterTime timeIntervalSince1970] + 30;
        NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
        if (now < expired) {
            // not expired yet
            return NO;
        }
        // handshake expired, return to 'connect' to do it again
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Connected;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];

    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Error;
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
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
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
    
    // target state: Error
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status == SGStarStatus_Error;
    };
    name = kDIMServerState_Error;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

//
//  state: Error
//
- (FSMState *)errorState {
    NSString *name = kDIMServerState_Error;
    FSMState *state = [[DIMServerState alloc] initWithName:name capacity:1];
    FSMBlockTransition *trans;
    FSMBlock block;
    
    // target state: Default
    block = ^BOOL(FSMMachine *machine, FSMTransition *transition) {
        DIMServer *server = [(DIMServerStateMachine *)machine server];
        SGStarStatus status = server.star.status;
        return status != SGStarStatus_Error;
    };
    name = kDIMServerState_Default;
    trans = [[FSMBlockTransition alloc] initWithTargetStateName:name block:block];
    [state addTransition:trans];
    
    return state;
}

@end
