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
//  DIMClientSession+State.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <FiniteStateMachine/FiniteStateMachine.h>

#import <DIMP/DIMClientSession.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMSessionStateBuilder;

/**
 *  Session States
 *  ~~~~~~~~~~~~~~
 *
 *      +--------------+                +------------------+
 *      |  0.Default   | .............> |   1.Connecting   |
 *      +--------------+                +------------------+
 *          A       A       ................:       :
 *          :       :       :                       :
 *          :       :       V                       V
 *          :   +--------------+        +------------------+
 *          :   |   5.Error    | <..... |   2.Connected    |
 *          :   +--------------+        +------------------+
 *          :       A       A                   A   :
 *          :       :       :................   :   :
 *          :       :                       :   :   V
 *      +--------------+                +------------------+
 *      |  4.Running   | <............. |  3.Handshaking   |
 *      +--------------+                +------------------+
 *
 */
@interface DIMSessionStateMachine : SMAutoMachine <SMContext>

@property(nonatomic, readonly) DIMClientSession *session;

@property(nonatomic, readonly, nullable) NSString *sessionKey;
@property(nonatomic, readonly, nullable) id<MKMID> sessionID;

@property(nonatomic, readonly) STDockerStatus status;

- (instancetype)initWithSession:(DIMClientSession *)session;

// pretected
- (DIMSessionStateBuilder *)createStateBuilder;

@end

#pragma mark -

typedef NS_ENUM(UInt8, DIMSessionStateOrder) {
    DIMSessionStateOrderDefault = 0,
    DIMSessionStateOrderConnecting,
    DIMSessionStateOrderConnected,
    DIMSessionStateOrderHandshaking,
    DIMSessionStateOrderRunning,
    DIMSessionStateOrderError
};

/**
 *  Session State
 *  ~~~~~~~~~~~~~
 *
 *  Defined for indicating session states
 *
 *      DEFAULT     - initialized
 *      CONNECTING  - connecting to station
 *      CONNECTED   - connected to station
 *      HANDSHAKING - trying to log in
 *      RUNNING     - handshake accepted
 *      ERROR       - network error
 */
@interface DIMSessionState : SMState

@property(nonatomic, readonly) NSTimeInterval enterTime;

@end

/**
 *  Session State Delegate
 *  ~~~~~~~~~~~~~~~~~~~~~~
 *
 *  callback when session state changed
 */
@protocol DIMSessionStateDelegate <SMDelegate>

@end

@class DIMSessionStateTransitionBuilder;

@interface DIMSessionStateBuilder : NSObject

- (instancetype)initWithTransitionBuilder:(DIMSessionStateTransitionBuilder *)builder;

- (DIMSessionState *)defaultState;

- (DIMSessionState *)connectingState;

- (DIMSessionState *)connectedState;

- (DIMSessionState *)handshakingState;

- (DIMSessionState *)runningState;

- (DIMSessionState *)errorState;

@end

#pragma mark -

/**
 *  Transitions
 *  ~~~~~~~~~~~
 *
 *      0.1 - when session ID was set, change state 'default' to 'connecting';
 *
 *      1.2 - when connection built, change state 'connecting' to 'connected';
 *      1.5 - if connection failed, change state 'connecting' to 'error';
 *
 *      2.3 - if no error occurs, change state 'connected' to 'handshaking';
 *      2.5 - if connection lost, change state 'connected' to 'error';
 *
 *      3.2 - if handshaking expired, change state 'handshaking' to 'connected';
 *      3.4 - when session key was set, change state 'handshaking' to 'running';
 *      3.5 - if connection lost, change state 'handshaking' to 'error';
 *
 *      4.0 - when session ID/key erased, change state 'running' to 'default';
 *      4.5 - when connection lost, change state 'running' to 'error';
 *
 *      5.0 - when connection reset, change state 'error' to 'default'.
 */
@interface DIMSessionStateTransition : SMBlockTransition

@end

/**
 *  Transition Builder
 *  ~~~~~~~~~~~~~~~~~~
 */
@interface DIMSessionStateTransitionBuilder : NSObject

/**
 *  Default -> Connecting
 *  ~~~~~~~~~~~~~~~~~~~~~
 *  When the session ID was set, and connection is building.
 *
 *  The session key must be empty now, it will be set
 *  after handshake success.
 */
- (DIMSessionStateTransition *)defaultConnectingTransition;

/**
 *  Connecting -> Connected
 *  ~~~~~~~~~~~~~~~~~~~~~~~
 *  When connection built.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)connectingConnectedTransition;

/**
 *  Connecting -> Error
 *  ~~~~~~~~~~~~~~~~~~~
 *  When connection lost.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)connectingErrorTransition;

/**
 *  Connected -> Handshaking
 *  ~~~~~~~~~~~~~~~~~~~~~~~~
 *  Do handshaking immediately after connected.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)connectedHandshakingTransition;

/**
 *  Connected -> Error
 *  ~~~~~~~~~~~~~~~~~~
 *  When connection lost.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)connectedErrorTransition;

/**
 *  Handshaking -> Running
 *  ~~~~~~~~~~~~~~~~~~~~~~
 *  When session key was set (handshake success).
 *
 *  The session ID must be set.
 */
- (DIMSessionStateTransition *)handshakingRunningTransition;

/**
 *  Handshaking -> Connected
 *  ~~~~~~~~~~~~~~~~~~~~~~~~
 *  When handshaking expired.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)handshakingConnectedTransition;

/**
 *  Handshaking -> Error
 *  ~~~~~~~~~~~~~~~~~~~~
 *  When connection lost.
 *
 *  The session ID must be set, and the session key must be empty now.
 */
- (DIMSessionStateTransition *)handshakingErrorTransition;

/**
 *  Running -> Default
 *  ~~~~~~~~~~~~~~~~~~
 *  When session id or session key was erased.
 *
 *  If session id was erased, it means user logout, the session key
 *  must be removed at the same time;
 *  If only session key was erased, but the session id kept the same,
 *  it means force the user login again.
 */
- (DIMSessionStateTransition *)runningDefaultTransition;

/**
 *  Running -> Error
 *  ~~~~~~~~~~~~~~~~
 *  When connection lost.
 */
- (DIMSessionStateTransition *)runningErrorTransition;

/**
 *  Error -> Default
 *  ~~~~~~~~~~~~~~~~
 *  When connection reset.
 */
- (DIMSessionStateTransition *)errorDefaultTransition;

@end

NS_ASSUME_NONNULL_END
