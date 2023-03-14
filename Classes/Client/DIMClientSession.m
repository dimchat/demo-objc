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
//  DIMClientSession.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamArrival.h"

#import "DIMClientSession.h"

@interface DIMClientSession () {
    
    NSString *_key;
}

@property(nonatomic, strong) __kindof id<MKMStation> station;

@property(nonatomic, strong) FSMThread *thread;

@end

@implementation DIMClientSession

- (instancetype)initWithDatabase:(id<DIMSessionDBI>)db
                         station:(id<MKMStation>)server {
    id<NIOSocketAddress> remote;
    remote = [[NIOInetSocketAddress alloc] initWithHost:server.host
                                                   port:server.port];
    if (self = [super initWithDatabase:db
                         remoteAddress:remote
                         socketChannel:nil]) {
        self.station = server;
        self.key = nil;
        self.thread = nil;
    }
    return self;
}

- (NSString *)key {
    return _key;
}

- (void)setKey:(nullable NSString *)key {
    _key = key;
}

- (void)start {
    NSAssert(!_thread, @"already started");
    FSMThread *thr = [[FSMThread alloc] initWithTarget:self];
    [thr start];
    self.thread = thr;
}

// Override
- (void)stop {
    [super stop];
    NSAssert(_thread, @"not start yet");
    FSMThread *thr = self.thread;
    [thr cancel];
    self.thread = nil;
}

// Override
- (void)setup {
    [self setActive:YES time:0];
    [super setup];
}

// Override
- (void)finish {
    [super finish];
    [self setActive:NO time:0];
}

//
//  Docker Delegate
//

// Override
- (void)docker:(id<STDocker>)worker changedStatus:(STDockerStatus)previous
      toStatus:(STDockerStatus)current {
    //[super docker:worker changedStatus:previous toStatus:current];
    if (current == STDockerStatusError) {
        // connection error or session finished
        // TODO: reconnect?
        [self setActive:NO time:0];
        // TODO: clear session ID and handshake again
    } else if (current == STDockerStatusReady) {
        // connected/ reconnected
        [self setActive:YES time:0];
    }
}

// Override
- (void)docker:(id<STDocker>)worker receivedShip:(id<STArrival>)arrival {
    //[super docker:worker receivedShip:arrival];
    NSMutableArray<NSData *> *allResponses = [[NSMutableArray alloc] init];
    DIMMessenger *messenger = [self messenger];
    // 1. get data packages from arrival ship's payload
    NSArray<NSData *> *packages = [self dataPackagesFromArrivalShip:arrival];
    NSArray<NSData *> *responses;
    for (NSData *pack in packages) {
        @try {
            // 2. process each data package
            responses = [messenger processData:pack];
            for (NSData *res in responses) {
                if ([res length] == 0) {
                    // should not happen
                    continue;
                }
                [allResponses addObject:res];
            }
        } @catch (NSException *ex) {
            NSLog(@"process error: %@", ex);
        } @finally {
        }
    }
    STCommonGate *gate = [self gate];
    id<NIOSocketAddress> source = [worker remoteAddress];
    id<NIOSocketAddress> destination = [worker localAddress];
    // 3. send responses separately
    for (NSData *res in responses) {
        [gate sendResponse:res forArrivalShip:arrival
             remoteAddress:source localAddress:destination];
    }
}

// private
- (NSArray<NSData *> *)dataPackagesFromArrivalShip:(id<STArrival>)arrival {
    STStreamArrival *ship = (STStreamArrival *)arrival;
    NSData *payload = [ship payload];
    // check payload
    if ([payload length] == 0) {
        return nil;
    } else {
        // TODO: split lines
        return @[payload];
    }
}

@end
