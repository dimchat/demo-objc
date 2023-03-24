// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMClientSession+State.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMClientSession+State.h"

@interface DIMSessionStateMachine ()

@property(nonatomic, strong) DIMClientSession *session;

@end

@implementation DIMSessionStateMachine

- (instancetype)initWithSession:(DIMClientSession *)session {
    if (self = [super init]) {
        self.session = session;
        // init states
        DIMSessionStateBuilder *builder = [self createStateBuilder];
        [self addState:builder.defaultState];
        [self addState:builder.connectingState];
        [self addState:builder.connectedState];
        [self addState:builder.handshakingState];
        [self addState:builder.runningState];
        [self addState:builder.errorState];
    }
    return self;
}

- (DIMSessionStateBuilder *)createStateBuilder {
    DIMSessionStateTransitionBuilder *stb;
    stb = [[DIMSessionStateTransitionBuilder alloc] init];
    return [[DIMSessionStateBuilder alloc] initWithTransitionBuilder:stb];
}

// Override
- (id<SMContext>)context {
    return self;
}

- (NSString *)sessionKey {
    return [_session key];
}

- (id<MKMID>)sessionID {
    return [_session ID];
}

- (STDockerStatus)status {
    STCommonGate *gate = [_session gate];
    id<NIOSocketAddress> remote = [_session remoteAddress];
    id<STDocker> docker = [gate dockerForAdvanceParty:nil
                                        remoteAddress:remote
                                         localAddress:nil];
    return docker ? [docker status] : STDockerStatusError;
}

@end

#pragma mark -

static NSArray *s_names = nil;

static inline NSString *get_name(DIMSessionStateOrder order) {
    OKSingletonDispatchOnce((^{
        s_names = @[
            @"DIMSessionStateOrderDefault",
            @"DIMSessionStateOrderConnecting",
            @"DIMSessionStateOrderConnected",
            @"DIMSessionStateOrderHandshaking",
            @"DIMSessionStateOrderRunning",
            @"DIMSessionStateOrderError",
        ];
    }));
    return [s_names objectAtIndex:order];
}

@interface DIMSessionState () {
    
    NSTimeInterval _enterTime;
}

@end

@implementation DIMSessionState

/* designated initializer */
- (instancetype)initWithIndex:(NSUInteger)stateIndex
                    capacity:(NSUInteger)countOfTransitions {
    if (self = [super initWithIndex:stateIndex capacity:countOfTransitions]) {
        _enterTime = 0;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[STConnectionState class]]) {
        if (self == object) {
            return YES;
        }
        STConnectionState *state = (STConnectionState *)object;
        return state.index == self.index;
    }
    return NO;
}

- (NSString *)description {
    return get_name([self index]);
}

- (NSString *)debugDescription {
    return get_name([self index]);
}

- (NSTimeInterval)enterTime {
    return _enterTime;
}

//
//  FSM Delegate
//

// Override
- (void)onEnter:(id<SMState>)previous machine:(id<SMContext>)ctx
           time:(NSTimeInterval)now {
    _enterTime = now;
}

// Override
- (void)onExit:(id<SMState>)next machine:(id<SMContext>)ctx
          time:(NSTimeInterval)now {
    _enterTime = 0;
}

// Override
- (void)onPaused:(id<SMContext>)ctx time:(NSTimeInterval)now {
    //
}

// Override
- (void)onResume:(id<SMContext>)ctx time:(NSTimeInterval)now {
    //
}

@end

static inline id<SMState> create_state(NSUInteger index, NSUInteger capacity) {
    return [[DIMSessionState alloc] initWithIndex:index capacity:capacity];
}

@interface DIMSessionStateBuilder ()

@property(nonatomic, strong) DIMSessionStateTransitionBuilder *stb;

@end

@implementation DIMSessionStateBuilder

- (instancetype)initWithTransitionBuilder:(DIMSessionStateTransitionBuilder *)builder {
    if (self = [super init]) {
        self.stb = builder;
    }
    return self;
}

- (DIMSessionState *)defaultState {
    DIMSessionState *state = create_state(DIMSessionStateOrderDefault, 1);
    // Default -> Connecting
    [state addTransition:_stb.defaultConnectingTransition];
    return state;
}

- (DIMSessionState *)connectingState {
    DIMSessionState *state = create_state(DIMSessionStateOrderConnecting, 2);
    // Connecting -> Connected
    [state addTransition:_stb.connectingConnectedTransition];
    // Connecting -> Error
    [state addTransition:_stb.connectingErrorTransition];
    return state;
}

- (DIMSessionState *)connectedState {
    DIMSessionState *state = create_state(DIMSessionStateOrderConnected, 2);
    // Connected -> Handshaking
    [state addTransition:_stb.connectedHandshakingTransition];
    // Connected -> Error
    [state addTransition:_stb.connectedErrorTransition];
    return state;
}

- (DIMSessionState *)handshakingState {
    DIMSessionState *state = create_state(DIMSessionStateOrderHandshaking, 3);
    // Handshaking -> Running
    [state addTransition:_stb.handshakingRunningTransition];
    // Handshaking -> Connected
    [state addTransition:_stb.handshakingConnectedTransition];
    // Handshaking -> Error
    [state addTransition:_stb.handshakingErrorTransition];
    return state;
}

- (DIMSessionState *)runningState {
    DIMSessionState *state = create_state(DIMSessionStateOrderRunning, 2);
    // Running -> Default
    [state addTransition:_stb.runningDefaultTransition];
    // Running -> Error
    [state addTransition:_stb.runningErrorTransition];
    return state;
}

- (DIMSessionState *)errorState {
    DIMSessionState *state = create_state(DIMSessionStateOrderError, 1);
    // Error -> Default
    [state addTransition:_stb.errorDefaultTransition];
    return state;
}

@end

#pragma mark -

@implementation DIMSessionStateTransition

@end

static inline BOOL state_expired(DIMSessionState *state, NSTimeInterval now) {
    NSTimeInterval enterTime = [state enterTime];
    return 0 < enterTime && enterTime < (now - 30);
}

static inline id<SMTransition> create_transition(NSUInteger stateIndex,
                                                 SMBlock block) {
    return [[DIMSessionStateTransition alloc] initWithTarget:stateIndex block:block];
}

@implementation DIMSessionStateTransitionBuilder

- (DIMSessionStateTransition *)defaultConnectingTransition {
    return create_transition(DIMSessionStateOrderConnecting,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // current user not set yet
            return NO;
        }
        STDockerStatus status = [ctx status];
        return status == STDockerStatusPreparing || status == STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)connectingConnectedTransition {
    return create_transition(DIMSessionStateOrderConnected,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        STDockerStatus status = [ctx status];
        return status == STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)connectingErrorTransition {
    return create_transition(DIMSessionStateOrderError,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if (state_expired([ctx currentState], now)) {
            // connecting expired, do it again
            return YES;
        }
        STDockerStatus status = [ctx status];
        return !(status == STDockerStatusPreparing || status == STDockerStatusReady);
    });
}

- (DIMSessionStateTransition *)connectedHandshakingTransition {
    return create_transition(DIMSessionStateOrderHandshaking,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // FIXME: current user lost?
            //        state will be changed to 'error'
            return NO;
        }
        STDockerStatus status = [ctx status];
        return status == STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)connectedErrorTransition {
    return create_transition(DIMSessionStateOrderError,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // FIXME: current user lost?
            return YES;
        }
        STDockerStatus status = [ctx status];
        return status != STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)handshakingRunningTransition {
    return create_transition(DIMSessionStateOrderRunning,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // FIXME: current user lost?
            //        state will be changed to 'error'
            return NO;
        }
        STDockerStatus status = [ctx status];
        if (status != STDockerStatusReady) {
            // connection lost, state will be changed to 'error'
            return NO;
        }
        // when current user changed, the session key will cleared, so
        // if it's set again, it means handshake success
        return [ctx sessionKey] != nil;
    });
}

- (DIMSessionStateTransition *)handshakingConnectedTransition {
    return create_transition(DIMSessionStateOrderConnected,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // FIXME: current user lost?
            //        state will be changed to 'error'
            return NO;
        }
        STDockerStatus status = [ctx status];
        if (status != STDockerStatusReady) {
            // connection lost, state will be changed to 'error'
            return NO;
        }
        if ([ctx sessionKey] != nil) {
            // session key was set, state will be changed to 'running'
            return NO;
        }
        // handshake expired? do it again
        return state_expired([ctx currentState], now);
    });
}

- (DIMSessionStateTransition *)handshakingErrorTransition {
    return create_transition(DIMSessionStateOrderError,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        if ([ctx sessionID] == nil) {
            // FIXME: current user lost?
            //        state will be changed to 'error'
            return YES;
        }
        STDockerStatus status = [ctx status];
        return status != STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)runningDefaultTransition {
    return create_transition(DIMSessionStateOrderDefault,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        STDockerStatus status = [ctx status];
        if (status != STDockerStatusReady) {
            // connection lost, state will be changed to 'error'
            return NO;
        }
        if ([ctx sessionID] == nil) {
            // user logout / switched?
            return YES;
        }
        // force user logiin again?
        return [ctx sessionKey] == nil;
    });
}

- (DIMSessionStateTransition *)runningErrorTransition {
    return create_transition(DIMSessionStateOrderError,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        STDockerStatus status = [ctx status];
        return status != STDockerStatusReady;
    });
}

- (DIMSessionStateTransition *)errorDefaultTransition {
    return create_transition(DIMSessionStateOrderDefault,
                             ^BOOL(DIMSessionStateMachine *ctx, NSTimeInterval now) {
        STDockerStatus status = [ctx status];
        return status != STDockerStatusError;
    });
}

@end
