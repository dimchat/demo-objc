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
//  DIMP
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

#import "DIMTerminal.h"

@interface DIMTerminal () {
    
    NSTimeInterval _lastOnlineTime;
}

@property(nonatomic, strong) id<DIMSessionDBI> database;

@property(nonatomic, strong) DIMCommonFacebook *facebook;
@property(nonatomic, strong) DIMClientMessenger *messenger;

@property(nonatomic, strong) DIMSessionStateMachine *fsm;

@property(nonatomic, strong) FSMThread *thread;

@end

@implementation DIMTerminal

- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack
                        database:(id<DIMSessionDBI>)sdb {
    if (self = [super init]) {
        self.facebook = barrack;
        self.database = sdb;
        self.messenger = nil;
        self.fsm = nil;
        self.thread = nil;
        _lastOnlineTime = 0;
        
    }
    return self;
}

- (__kindof DIMClientSession *)session {
    return [_messenger session];
}

- (DIMSessionState *)state {
    return [_fsm currentState];
}

//#pragma mark DIMStationDelegate
//
//static NSData *sn_start = nil;
//static NSData *sn_end = nil;
//
//static inline NSData *fetch_sn(NSData *data) {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sn_start = MKMUTF8Encode(@"Mars SN:");
//        sn_end = MKMUTF8Encode(@"\n");
//    });
//
//    NSData *sn = nil;
//    NSRange range = NSMakeRange(0, sn_start.length);
//    if (data.length > sn_start.length && [[data subdataWithRange:range] isEqualToData:sn_start]) {
//        range = NSMakeRange(0, data.length);
//        range = [data rangeOfData:sn_end options:0 range:range];
//        if (range.location > sn_start.length) {
//            range = NSMakeRange(0, range.location + range.length);
//            sn = [data subdataWithRange:range];
//        }
//    }
//    return sn;
//}
//
//static inline NSData *merge_data(NSData *data1, NSData *data2) {
//    NSUInteger len1 = data1.length;
//    NSUInteger len2 = data2.length;
//    if (len1 == 0) {
//        return data2;
//    } else if (len2 == 0) {
//        return data1;
//    }
//    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:(len1 + len2)];
//    [mData appendData:data1];
//    [mData appendData:data2];
//    return mData;
//}
//
//static inline bool starts_with(NSData *data, unsigned char b) {
//    if ([data length] == 0) {
//        return false;
//    }
//    unsigned char *buffer = (unsigned char *)[data bytes];
//    return buffer[0] == b;
//}
//
//static inline NSArray<NSData *> *split_lines(NSData *data) {
//    NSMutableArray *mArray = [[NSMutableArray alloc] init];
//    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
//        unsigned char *buffer = (unsigned char *)bytes;
//        NSUInteger pos1 = byteRange.location, pos2;
//        while (pos1 < byteRange.length) {
//            pos2 = pos1;
//            while (pos2 < byteRange.length) {
//                if (buffer[pos2] == '\n') {
//                    break;
//                } else {
//                    ++pos2;
//                }
//            }
//            if (pos2 > pos1) {
//                [mArray addObject:[data subdataWithRange:NSMakeRange(pos1, pos2 - pos1)]];
//            }
//            pos1 = pos2 + 1;  // skip '\n'
//        }
//    }];
//    return mArray;
//}
//
//- (void)station:(DIMStation *)server onReceivePackage:(NSData *)data {
//    // 0. fetch SN from data head
//    NSData *head = fetch_sn(data);
//    if (head.length > 0) {
//        NSRange range = NSMakeRange(head.length, data.length - head.length);
//        data = [data subdataWithRange:range];
//    }
//    // 1. split data when multi packages received one time
//    NSArray<NSData *> *packages;
//    if ([data length] == 0) {
//        packages = @[];
//    } else if (starts_with(data, '{')) {
//        // JSON format
//        //     the data buffer may contain multi messages (separated by '\n'),
//        //     so we should split them here.
//        packages = split_lines(data);
//    } else {
//        // FIXME: other format?
//        packages = @[data];
//    }
//    // 2. process package data one by one
//    DIMMessenger *messenger = [DIMMessenger sharedInstance];
//    NSData *SEPARATOR = MKMUTF8Encode(@"\n");
//    NSMutableData *mData = [[NSMutableData alloc] init];
//    NSArray<NSData *> *responses;
//    for (NSData *pack in packages) {
//        responses = [messenger processData:pack];
//        // combine responses
//        for (NSData *res in responses) {
//            [mData appendData:res];
//            [mData appendData:SEPARATOR];
//        }
//    }
//    if ([mData length] > 0) {
//        // drop last '\n'
//        data = [mData subdataWithRange:NSMakeRange(0, [mData length] - 1)];
//    } else {
//        data = nil;
//    }
//    if (head.length > 0 || [data length] > 0) {
//        // NOTICE: sending 'SN' back to the server for confirming
//        //         that the client have received the pushing message
//        [_currentStation.star send:merge_data(head, data)];
//    }
//}
//
//- (void)station:(DIMStation *)server onHandshakeAccepted:(NSString *)session {
//    DIMMessenger *messenger = [DIMMessenger sharedInstance];
//    id<MKMUser> user = self.currentUser;
//    // post contacts(encrypted) to station
//    NSArray<id<MKMID>> *contacts = user.contacts;
//    if (contacts) {
//        [messenger postContacts:contacts];
//    }
//    // broadcast login command
//    DIMLoginCommand *login = [[DIMLoginCommand alloc] initWithID:user.ID];
//    [login setAgent:self.userAgent];
//    [login copyStationInfo:server];
//    //[login copyProviderInfo:server.SP];
//    [messenger broadcastContent:login];
//}

// Override
- (void)finish {
    // stop state machine
    DIMSessionStateMachine *machine = [self fsm];
    if (machine) {
        [machine stop];
        self.fsm = nil;
    }
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
    [FSMRunner idle:16.0];
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
    if (!uid || [self state].index != DIMSessionStateOrderRunning) {
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
- (void)machine:(id<FSMContext>)ctx enterState:(id<FSMState>)next
           time:(NSTimeInterval)now {
    // called before state changed
}

// Override
- (void)machine:(DIMSessionStateMachine *)ctx exitState:(id<FSMState>)previous
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
- (void)machine:(id<FSMContext>)ctx pauseState:(id<FSMState>)current
           time:(NSTimeInterval)now {
    
}

// Override
- (void)machine:(id<FSMContext>)ctx resumeState:(id<FSMState>)current
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
    [session start];
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
    }
    // stop the machine & remove old messenger
    DIMSessionStateMachine *machine = [self fsm];
    if (machine) {
        [machine stop];
        self.fsm = nil;
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
    // create & start state machine
    machine = [[DIMSessionStateMachine alloc] initWithSession:session];
    [machine setDelegate:self];
    [machine start];
    self.fsm = machine;
    self.messenger = messenger;
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
    DIMSessionStateMachine *machine = [self fsm];
    if (!messenger || !machine) {
        // not connect
        return;
    }
    // check signed in user
    DIMClientSession *session = [messenger session];
    id<MKMID> uid = [session ID];
    if (uid) {
        // already signed in, check session state
        DIMSessionState *state = [machine currentState];
        if (state.index == DIMSessionStateOrderRunning) {
            // report client state
            [messenger reportOfflineForID:uid];
            // TODO: idle(0.5)?
        }
    }
    // pause the session
    [machine pause];
}

- (void)enterForeground {
    DIMClientMessenger *messenger = [self messenger];
    DIMSessionStateMachine *machine = [self fsm];
    if (!messenger || !machine) {
        // not connect
        return;
    }
    // resume the session
    [machine resume];

    // check signed in user
    DIMClientSession *session = [messenger session];
    id<MKMID> uid = [session ID];
    if (uid) {
        // already signed in, wait a while to check session state
        [NSObject performBlockInBackground:^{
            DIMSessionState *state = [machine currentState];
            if (state.index == DIMSessionStateOrderRunning) {
                // report client state
                [messenger reportOnlineForID:uid];
            }
        } afterDelay:2.0];
    }
}

- (void)start {
    FSMThread *thr = self.thread;
    if (!thr) {
        thr = [[FSMThread alloc] initWithTarget:self];
        [thr start];
        self.thread = thr;
    }
}

@end
