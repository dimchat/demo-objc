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
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "NSObject+Threading.h"

#import "DIMLoginCommand.h"
#import "DIMReportCommand.h"

#import "DIMCommonFacebook.h"
#import "DIMClientMessagePacker.h"
#import "DIMClientMessageProcessor.h"
#import "DIMClientMessenger.h"
#import "DIMGroupManager.h"

#import "DIMTerminal.h"

@interface DIMTerminal () {
    
    NSTimeInterval _lastOnlineTime;
}

@property(nonatomic, strong) id<DIMSessionDBI> database;

@property(nonatomic, strong) DIMCommonFacebook *facebook;
@property(nonatomic, strong) DIMClientMessenger *messenger;

@end

@implementation DIMTerminal

- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack
                        database:(id<DIMSessionDBI>)sdb {
    if (self = [super init]) {
        self.facebook = barrack;
        self.database = sdb;
        self.messenger = nil;
        _lastOnlineTime = 0;
        
    }
    return self;
}

- (__kindof DIMClientSession *)session {
    return [_messenger session];
}

// Override
- (void)finish {
    // stop session in messenger
    DIMMessenger *messenger = [self messenger];
    if (messenger) {
        DIMClientSession *session = [self session];
        [session stop];
        self.messenger = nil;
    }
    [super finish];
}

// Override
- (void)idle {
    [SMRunner idle:16.0];
}

// protected
- (BOOL)isOnlineExpired:(NSTimeInterval)now {
    // keep online every 5 minutes
    return now < (_lastOnlineTime + 300);
}

// Override
- (BOOL)process {
    // check timeout
    NSTimeInterval now = OKGetCurrentTimeInterval();
    if (![self isOnlineExpired:now]) {
        // not expired yet
        return NO;
    }
    // check session state
    DIMClientMessenger *messenger = [self messenger];
    if (!messenger) {
        // not connect
        return NO;
    }
    DIMClientSession *session = [messenger session];
    id<MKMID> uid = [session ID];
    DIMSessionState *state = session.state;
    if (!uid || state.index != DIMSessionStateOrderRunning) {
        // handshake not accepted
        return NO;
    }
    // report every 5 minutes to keep user online
    @try {
        [self keepOnlineForID:uid];
    } @catch (NSException *ex) {
    } @finally {
    }
    // update last online time
    _lastOnlineTime = now;
    return NO;
}

//
//  FSM Delegate
//

// Override
- (void)machine:(id<SMContext>)ctx enterState:(id<SMState>)next
           time:(NSTimeInterval)now {
    // called before state changed
}

// Override
- (void)machine:(DIMSessionStateMachine *)ctx exitState:(id<SMState>)previous
           time:(NSTimeInterval)now {
    DIMSessionState *current = [ctx currentState];
    if (!current) {
        return;
    }
    if (current.index == DIMSessionStateOrderHandshaking) {
        // start handshake
        [self.messenger handshake:nil];
    } else if (current.index == DIMSessionStateOrderRunning) {
        // broadcast current meta & visa document to all stations
        [self.messenger handshakeSuccess];
        // update last online time
        _lastOnlineTime = now;
    }
}

// Override
- (void)machine:(id<SMContext>)ctx pauseState:(id<SMState>)current
           time:(NSTimeInterval)now {
    
}

// Override
- (void)machine:(id<SMContext>)ctx resumeState:(id<SMState>)current
           time:(NSTimeInterval)now {
    // TODO: clear session key for re-login?
}

@end

@implementation DIMTerminal (Device)

- (NSString *)userAgent {
    // TODO: build user-agent
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

- (NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    return languages.firstObject;
}

@end

@implementation DIMTerminal (Creation)

- (id<MKMStation>)createStationWithHost:(NSString *)ip port:(UInt16)port {
    DIMStation *station = [[DIMStation alloc] initWithHost:ip port:port];
    [station setDataSource:_facebook];
    return station;
}

- (DIMClientSession *)createSessionWithStation:(id<MKMStation>)server {
    DIMClientSession *session;
    session = [[DIMClientSession alloc] initWithDatabase:_database
                                                 station:server];
    // set current user for handshaking
    id<MKMUser> user = [_facebook currentUser];
    if (user) {
        [session setID:user.ID];
    }
    [session startWithStateDelegate:self];
    return session;
}

- (id<DIMPacker>)createPackerWithFacebook:(DIMCommonFacebook *)barrack
                                messenger:(DIMClientMessenger *)transceiver {
    return [[DIMClientMessagePacker alloc] initWithFacebook:barrack
                                                  messenger:transceiver];
}

- (id<DIMProcessor>)createProcessorWithFacebook:(DIMCommonFacebook *)barrack
                                      messenger:(DIMClientMessenger *)transceiver {
    return [[DIMClientMessageProcessor alloc] initWithFacebook:barrack
                                                     messenger:transceiver];
}

- (DIMClientMessenger *)createMessengerWithFacebook:(DIMCommonFacebook *)barrack
                                            session:(DIMClientSession *)session {
    NSAssert(false, @"override me!");
    return nil;
}

@end

@implementation DIMTerminal (State)

- (DIMClientMessenger *)connectToHost:(NSString *)ip port:(UInt16)port {
    DIMClientMessenger *messenger = [self messenger];
    if (messenger) {
        DIMClientSession *session = [messenger session];
        if ([session isActive]) {
            // current session is active
            id<MKMStation> station = [session station];
            if (station.port == port && [station.host isEqualToString:ip]) {
                // same target
                return messenger;
            }
        }
        [session stop];
    }
    DIMCommonFacebook *facebook = [self facebook];
    
    // create new messenger with session
    id<MKMStation> station = [self createStationWithHost:ip port:port];
    DIMClientSession *session = [self createSessionWithStation:station];
    messenger = [self createMessengerWithFacebook:facebook session:session];
    // create packer, processor for messenger
    // they have weak references to facebook & messenger
    [messenger setPacker:[self createPackerWithFacebook:facebook
                                              messenger:messenger]];
    [messenger setProcessor:[self createProcessorWithFacebook:facebook
                                                    messenger:messenger]];
    // set weak reference to messenger
    [session setMessenger:messenger];
    self.messenger = messenger;
    [DIMGroupManager sharedInstance].messenger = messenger;
    return messenger;
}

- (BOOL)loginWithID:(id<MKMID>)user {
    DIMClientSession *session = [self session];
    if (session) {
        [session setID:user];
        return YES;
    } else {
        return NO;
    }
}

- (void)keepOnlineForID:(id<MKMID>)user {
    // send login command to everyone to provide more information.
    // this command can keep the user online too.
    DIMClientMessenger *messenger = [self messenger];
    [messenger broadcastLoginForID:user userAgent:self.userAgent];
}

- (void)enterBackground {
    DIMClientMessenger *messenger = [self messenger];
    if (!messenger) {
        // not connect
        return;
    }
    // check signed in user
    DIMClientSession *session = [messenger session];
    id<MKMID> uid = [session ID];
    if (uid) {
        // already signed in, check session state
        DIMSessionState *state = [session state];
        if (state.index == DIMSessionStateOrderRunning) {
            // report client state
            [messenger reportOfflineForID:uid];
            // TODO: idle(0.5)?
        }
    }
    // pause the session
    [session pause];
}

- (void)enterForeground {
    DIMClientMessenger *messenger = [self messenger];
    if (!messenger) {
        // not connect
        return;
    }
    // resume the session
    DIMClientSession *session = [messenger session];
    [session resume];

    // check signed in user
    id<MKMID> uid = [session ID];
    if (uid) {
        // already signed in, wait a while to check session state
        [NSObject performBlockInBackground:^{
            DIMSessionState *state = [session state];
            if (state.index == DIMSessionStateOrderRunning) {
                // report client state
                [messenger reportOnlineForID:uid];
            }
        } afterDelay:2.0];
    }
}

- (void)start {
    SMThread *thr = [[SMThread alloc] initWithTarget:self];
    [thr start];
}

@end
