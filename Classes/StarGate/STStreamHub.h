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
//  STStreamHub.h
//  DIMClient
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMClient/STStreamChannel.h>

NS_ASSUME_NONNULL_BEGIN

@interface STStreamHub : STHub

// protected
- (STAddressPairMap<id<STChannel>> *)createChannelPool;

@end

// protected
@interface STStreamHub (Channel)

/**
 *  Create channel with socket & addresses
 *
 * @param sock   - socket
 * @param remote - remote address
 * @param local  - local address
 * @return null on socket error
 */
- (id<STChannel>)createChannelWithSocketChannel:(NIOSocketChannel *)sock
                                  remoteAddress:(id<NIOSocketAddress>)remote
                                   localAddress:(nullable id<NIOSocketAddress>)local;

- (id<STChannel>)channelForRemoteAddress:(id<NIOSocketAddress>)remote
                            localAddress:(nullable id<NIOSocketAddress>)local;

- (void)setChannel:(id<STChannel>)channel
     remoteAddress:(id<NIOSocketAddress>)remote
      localAddress:(nullable id<NIOSocketAddress>)local;

@end

@interface STClientHub : STStreamHub

// protected
- (id<STChannel>)createSocketChannelForRemoteAddress:(id<NIOSocketAddress>)remote
                                        localAddress:(id<NIOSocketAddress>)local;

@end

@interface STStreamClientHub : STClientHub

- (void)putChannel:(STStreamChannel *)channel;

@end

NS_ASSUME_NONNULL_END
