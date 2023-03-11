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
//  STCommonGate.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMP/STStreamHub.h>

NS_ASSUME_NONNULL_BEGIN

@interface STBaseGate<__covariant Hub : id<STHub>> : STGate

@property(nonatomic, strong) Hub hub;

@end

@interface STBaseGate (Docker)

- (id<STDocker>)dockerForAdvanceParty:(nullable NSArray<NSData *> *)advanceParty
                        remoteAddress:(id<NIOSocketAddress>)remote
                         localAddress:(nullable id<NIOSocketAddress>)local;

@end

@interface STCommonGate : STBaseGate<STStreamHub *>

@property(nonatomic, readonly, getter=isRunning) BOOL running;

- (void)start;
- (void)stop;

- (id<STChannel>)channelForRemoteAddress:(id<NIOSocketAddress>)remote
                            localAddress:(nullable id<NIOSocketAddress>)local;

- (BOOL)sendResponse:(NSData *)payload
      forArrivalShip:(id<STArrival>)income
       remoteAddress:(id<NIOSocketAddress>)remote
        localAddress:(nullable id<NIOSocketAddress>)local;

@end

/**
 *  TCP Client Gate
 */
@interface STTCPClientGate : STCommonGate

@end

NS_ASSUME_NONNULL_END
