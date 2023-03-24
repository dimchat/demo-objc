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
//  STStreamHub.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamHub.h"

@interface __ChannelPool : STAddressPairMap<id<STChannel>>

@end

@implementation __ChannelPool

// Override
- (void)setObject:(id<STChannel>)value
        forRemote:(nullable id)remote local:(nullable id)local {
    id<STChannel> old = [self objectForRemote:remote local:local];
    if (old && old != value) {
        [self removeObject:old forRemote:remote local:local];
    }
    [super setObject:value forRemote:remote local:local];
}

// Override
- (id<STChannel>)removeObject:(nullable id<STChannel>)value
                    forRemote:(nullable id)remote local:(nullable id)local {
    id<STChannel> cached = [super removeObject:value forRemote:remote local:local];
    if ([cached isOpen]) {
        [cached close];
    }
    return cached;
}

@end

#pragma mark -

@interface STStreamHub ()

@property(nonatomic, strong) STAddressPairMap<id<STChannel>> *channelPool;

@end

@implementation STStreamHub

- (instancetype)initWithConnectionDelegate:(id<STConnectionDelegate>)delegate {
    if (self = [super initWithConnectionDelegate:delegate]) {
        self.channelPool = [self createChannelPool];
    }
    return self;
}

- (STAddressPairMap<id<STChannel>> *)createChannelPool {
    return [[__ChannelPool alloc] init];
}

@end

@implementation STStreamHub (Channel)

- (id<STChannel>)createChannelWithSocketChannel:(NIOSocketChannel *)sock
                                  remoteAddress:(id<NIOSocketAddress>)remote
                                   localAddress:(nullable id<NIOSocketAddress>)local {
    return [[STStreamChannel alloc] initWithSocket:sock
                                     remoteAddress:remote
                                      localAddress:local];
}

// Override
- (NSSet<id<STChannel>> *)allChannels {
    return [_channelPool allValues];
}

- (id<STChannel>)channelForRemoteAddress:(id<NIOSocketAddress>)remote
                            localAddress:(nullable id<NIOSocketAddress>)local {
    return [_channelPool objectForRemote:remote local:local];
}

- (void)setChannel:(id<STChannel>)channel
     remoteAddress:(id<NIOSocketAddress>)remote
      localAddress:(nullable id<NIOSocketAddress>)local {
    [_channelPool setObject:channel forRemote:remote local:local];
}

// Override
- (void)removeChannel:(id<STChannel>)channel
        remoteAddress:(id<NIOSocketAddress>)remote
         localAddress:(id<NIOSocketAddress>)local {
    [_channelPool removeObject:channel forRemote:remote local:local];
}

// Override
- (id<STChannel>)openChannelForRemoteAddress:(id<NIOSocketAddress>)remote localAddress:(id<NIOSocketAddress>)local {
    NSAssert(remote, @"remote address empty");
    // get channel connected to remote address
    return [self channelForRemoteAddress:remote localAddress:local];
}

@end

#pragma mark -

@implementation STClientHub

// Override
- (id<STConnection>)createConnectionWithChannel:(id<STChannel>)channel
                                  remoteAddress:(id<NIOSocketAddress>)remote
                                   localAddress:(id<NIOSocketAddress>)local {
    STActiveConnection *conn;
    conn = [[STActiveConnection alloc] initWithHub:self
                                           channel:channel
                                     remoteAddress:remote
                                      localAddress:local];
    [conn setDelegate:self.delegate];  // gate
    [conn start];  // start FSM
    return conn;
}

// Override
- (id<STChannel>)openChannelForRemoteAddress:(id<NIOSocketAddress>)remote
                                localAddress:(id<NIOSocketAddress>)local {
    id<STChannel> channel = [super openChannelForRemoteAddress:remote
                                                  localAddress:local];
    if (!channel/* && remote*/) {
        channel = [self createSocketChannelForRemoteAddress:remote
                                               localAddress:local];
        if (channel) {
            local = [channel localAddress];
            [self setChannel:channel remoteAddress:remote localAddress:local];
        }
    }
    return channel;
}

// protected
- (id<STChannel>)createSocketChannelForRemoteAddress:(id<NIOSocketAddress>)remote
                                        localAddress:(id<NIOSocketAddress>)local {
    NSAssert(false, @"override me!");
    return nil;
}

@end

@implementation STStreamClientHub

- (void)putChannel:(STStreamChannel *)channel {
    [self setChannel:channel
       remoteAddress:channel.remoteAddress
        localAddress:channel.localAddress];
}

// Override
- (id<STConnection>)connectionWithRemoteAddress:(id<NIOSocketAddress>)remote
                                   localAddress:(id<NIOSocketAddress>)local {
    return [super connectionWithRemoteAddress:remote localAddress:nil];
}

// Override
- (void)setConnection:(id<STConnection>)conn
        remoteAddress:(id<NIOSocketAddress>)remote
         localAddress:(id<NIOSocketAddress>)local {
    [super setConnection:conn remoteAddress:remote localAddress:nil];
}

// Override
- (void)removeConnection:(id<STConnection>)conn
           remoteAddress:(id<NIOSocketAddress>)remote
            localAddress:(id<NIOSocketAddress>)local {
    [super removeConnection:conn remoteAddress:remote localAddress:nil];
}

@end
