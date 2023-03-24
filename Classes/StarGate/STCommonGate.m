// license: https://mit-license.org
//
//  Star Gate: Network Connection Module
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
//  STCommonGate.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamDocker.h"

#import "STCommonGate.h"

@implementation STBaseGate

// Override
- (id<STDocker>)dockerWithRemoteAddress:(id<NIOSocketAddress>)remote
                           localAddress:(id<NIOSocketAddress>)local {
    return [super dockerWithRemoteAddress:remote localAddress:nil];
}

// Override
- (void)setDocker:(id<STDocker>)worker
    remoteAddress:(id<NIOSocketAddress>)remote
     localAddress:(id<NIOSocketAddress>)local {
    [super setDocker:worker remoteAddress:remote localAddress:nil];
}

// Override
- (void)removeDocker:(id<STDocker>)worker
       remoteAddress:(id<NIOSocketAddress>)remote
        localAddress:(id<NIOSocketAddress>)local {
    [super removeDocker:worker remoteAddress:remote localAddress:nil];
}

/*/
// Override
- (void)heartbeat:(id<STConnection>)connection {
    // let the client to do the job
    if ([connection isKindOfClass:[STActiveConnection class]]) {
        [super heartbeat:connection];
    }
}
/*/

// Override
- (NSArray<NSData *> *)cacheAdvanceParty:(NSData *)data
                           forConnection:(id<STConnection>)conn {
    // TODO: cache the advance party before decide which docker to use
    if ([data length] > 0) {
        return @[data];
    } else {
        return nil;
    }
}

// Override
- (void)clearAdvancePartyForConnection:(id<STConnection>)conn {
    // TODO: remove advance party for this connection
}

@end

@implementation STBaseGate (Docker)

- (id<STDocker>)dockerForAdvanceParty:(nullable NSArray<NSData *> *)advanceParty
                        remoteAddress:(id<NIOSocketAddress>)remote
                         localAddress:(nullable id<NIOSocketAddress>)local {
    id<STDocker> docker = [self dockerWithRemoteAddress:remote
                                           localAddress:local];
    if (!docker) {
        id<STConnection> conn = [_hub connectToRemoteAddress:remote
                                                localAddress:local];
        if (conn) {
            docker = [self createDockerWithConnection:conn
                                         advanceParty:advanceParty];
            NSAssert(docker, @"failed to create docker: %@, %@", remote, local);
            [self setDocker:docker remoteAddress:remote localAddress:local];
        }
    }
    return docker;
}

@end

#pragma mark -

@interface STCommonGate () {
    
    BOOL _running;
}

@end

@implementation STCommonGate

- (instancetype)initWithDockerDelegate:(id<STDockerDelegate>)delegate {
    if (self = [super initWithDockerDelegate:delegate]) {
        _running = NO;
    }
    return self;
}

- (BOOL)isRunning {
    return _running;
}

- (void)start {
    _running = YES;
}

- (void)stop {
    _running = NO;
}

- (id<STChannel>)channelForRemoteAddress:(id<NIOSocketAddress>)remote
                            localAddress:(nullable id<NIOSocketAddress>)local {
    id<STHub> hub = [self hub];
    NSAssert(hub, @"no hub for channel: %@, %@", remote, local);
    return [hub openChannelForRemoteAddress:remote localAddress:local];
}

- (BOOL)sendResponse:(NSData *)payload forArrivalShip:(id<STArrival>)income
       remoteAddress:(id<NIOSocketAddress>)remote
        localAddress:(id<NIOSocketAddress>)local {
    // pack payload and call docker to send out
    id<STDocker> docker = [self dockerForAdvanceParty:nil
                                        remoteAddress:remote
                                         localAddress:local];
    NSAssert([docker isKindOfClass:[STStreamDocker class]], @"docker error: %@", docker);
    return [docker sendData:payload];
}

@end

@implementation STTCPClientGate

// Override
- (id<STDocker>)createDockerWithConnection:(id<STConnection>)conn
                              advanceParty:(NSArray<NSData *> *)data {
    STStreamDocker *docker = [[STStreamDocker alloc] initWithConnection:conn];
    [docker setDelegate:self.delegate];
    return docker;
}

// Override
- (void)heartbeat:(id<STConnection>)connection {
    // let the client to do the job
    if ([connection isKindOfClass:[STActiveConnection class]]) {
        [super heartbeat:connection];
    }
}

@end
