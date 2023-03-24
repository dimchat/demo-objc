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
//  DIMGateKeeper.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamDocker.h"

#import "DIMGateKeeper.h"

@interface DIMGateKeeper () {
    
    BOOL _active;
    NSTimeInterval _lastActive;  // last update time
}

@property(nonatomic, strong) id<NIOSocketAddress> remoteAddress;

@property(nonatomic, strong) STCommonGate *gate;

@property(nonatomic, strong) DIMMessageQueue *queue;

@end

@implementation DIMGateKeeper

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    id<NIOSocketAddress> remote = nil;
    NIOSocketChannel *sock = nil;
    return [self initWithRemoteAddress:remote socketChannel:sock];
}

/* designated initializer */
- (instancetype)initWithRemoteAddress:(id<NIOSocketAddress>)remote
                        socketChannel:(NIOSocketChannel *)sock {
    if (self = [super init]) {
        self.remoteAddress = remote;
        self.gate = [self createGateForRemoteAddress:remote socketChannel:sock];
        self.queue = [DIMMessageQueue queue];
        _active = NO;
        _lastActive = 0;
    }
    return self;
}

- (STCommonGate *)createGateForRemoteAddress:(id<NIOSocketAddress>)remote
                               socketChannel:(NIOSocketChannel *)sock {
    STCommonGate *streamGate;
    if (sock) {
        NSAssert(false, @"should not happen");
    } else {
        streamGate = [[STTCPClientGate alloc] initWithDockerDelegate:self];
    }
    STStreamHub *hub = [self createHubForRemoteAddress:remote
                                         socketChannel:sock
                                              delegate:streamGate];
    [streamGate setHub:hub];
    return streamGate;
}

- (STStreamHub *)createHubForRemoteAddress:(id<NIOSocketAddress>)remote
                             socketChannel:(NIOSocketChannel *)sock
                                  delegate:(id<STConnectionDelegate>)gate {
    STStreamHub *streamHub;
    if (sock) {
        NSAssert(false, @"should not happen");
    } else {
        // client
        streamHub = [[STStreamClientHub alloc] initWithConnectionDelegate:gate];
        id<STConnection> conn = [streamHub connectToRemoteAddress:remote
                                                     localAddress:nil];
        if (!conn) {
            NSAssert(false, @"failed to connect remote: %@", remote);
        }
        // TODO: reset send buffer size
    }
    return streamHub;
}

- (BOOL)isActive {
    return _active;
}

- (BOOL)setActive:(BOOL)flag time:(NSTimeInterval)when {
    if (_active == flag) {
        // flag not changed
        return NO;
    }
    if (when < 1) {
        when = OKGetCurrentTimeInterval();
    } else if (when <= _lastActive) {
        return NO;
    }
    _active = flag;
    _lastActive = when;
    return YES;
}

// Override
- (BOOL)isRunning {
    if ([super isRunning]) {
        return [_gate isRunning];
    } else {
        return NO;
    }
}

// Override
- (void)stop {
    [super stop];
    [_gate stop];
}

// Override
- (void)setup {
    [super setup];
    [_gate start];
}

// Override
- (void)finish {
    [_gate stop];
    [super finish];
}

// Override
- (BOOL)process {
    id<STHub> hub = [_gate hub];
    @try {
        BOOL incoming = [hub process];
        BOOL outgoing = [_gate process];
        if (incoming || outgoing) {
            // processed income/outgo packages
            return YES;
        }
    } @catch (NSException *e) {
        NSLog(@"gate error: %@", e);
        return NO;
    }
    if (![self isActive]) {
        // inactive, wait a while to check again
        [_queue purge];
        return NO;
    }
    // get next message
    DIMMessageWrapper *wrapper = [_queue nextTask];
    if (!wrapper) {
        // no more task now, purge failed task
        [_queue purge];
        return NO;
    }
    // if msg in this wrapper is null (means sent successfully),
    // it must have bean cleaned already, so iit should not be empty here
    id<DKDReliableMessage> rMsg = [wrapper message];
    if (!rMsg) {
        // msg sent?
        return YES;
    }
    // try to push
    BOOL ok = [_gate sendShip:wrapper remoteAddress:_remoteAddress localAddress:nil];
    if (!ok) {
        NSLog(@"gate error, failed to send data");
    }
    return YES;
}

- (id<STDeparture>)departureByPackData:(NSData *)payload priority:(NSInteger)prior {
    id<STDocker> docker = [_gate dockerForAdvanceParty:nil
                                         remoteAddress:_remoteAddress
                                          localAddress:nil];
    NSAssert([docker conformsToProtocol:@protocol(STDeparturePacker)], @"departure packer error: %@", docker);
    id<STDeparturePacker> packer = (id<STDeparturePacker>)docker;
    return [packer departureByPackData:payload priority:prior];
}

- (BOOL)appendReliableMessage:(id<DKDReliableMessage>)rMsg
                departureShip:(id<STDeparture>)outgo {
    return [_queue appendReliableMessage:rMsg departureShip:outgo];
}

//
//  Docker.Delegate
//

// Override
- (void)docker:(id<STDocker>)worker changedStatus:(STDockerStatus)previous
      toStatus:(STDockerStatus)current {
    NSLog(@"docker status changed: %d => %d, %@", previous, current, worker);
}

// Override
- (void)docker:(id<STDocker>)worker receivedShip:(id<STArrival>)arrival {
    NSLog(@"docker received a ship: %@, %@", arrival, worker);
}

// Override
- (void)docker:(id<STDocker>)worker sentShip:(id<STDeparture>)departure {
    // TODO: remove sent message from local cache
}

// Override
- (void)docker:(id<STDocker>)worker failedToSendShip:(id<STDeparture>)departure
         error:(NIOError *)error {
    NSLog(@"docker failed to send ship: %@", error);
}

// Override
- (void)docker:(id<STDocker>)worker sendingShip:(id<STDeparture>)departure
         error:(NIOError *)error {
    NSLog(@"docker error while sending ship: %@", error);
}

@end
