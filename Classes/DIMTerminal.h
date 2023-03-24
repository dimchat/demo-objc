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
//  DIMTerminal.h
//  DIMP
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMP/DIMClientSession+State.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMTerminal : SMRunner <DIMSessionStateDelegate>

@property(nonatomic, readonly) __kindof id<DIMSessionDBI> database;

@property(nonatomic, readonly) __kindof DIMCommonFacebook *facebook;
@property(nonatomic, readonly) __kindof DIMClientMessenger *messenger;
@property(nonatomic, readonly) __kindof DIMClientSession *session;

@property(nonatomic, readonly, nullable) DIMSessionState *state;

- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack database:(id<DIMSessionDBI>)sdb;

@end

@interface DIMTerminal (Device)

/**
 *  format: "DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1"
 */
@property (readonly, nonatomic, nullable) NSString *userAgent;

@property (readonly, nonatomic) NSString *language;

@end

// protected
@interface DIMTerminal (Creation)

- (id<MKMStation>)createStationWithHost:(NSString *)ip port:(UInt16)port;

- (DIMClientSession *)createSessionWithStation:(id<MKMStation>)server;

- (id<DIMPacker>)createPackerWithFacebook:(DIMCommonFacebook *)barrack
                                messenger:(DIMClientMessenger *)transceiver;

- (id<DIMProcessor>)createProcessorWithFacebook:(DIMCommonFacebook *)barrack
                                      messenger:(DIMClientMessenger *)transceiver;

- (DIMClientMessenger *)createMessengerWithFacebook:(DIMCommonFacebook *)barrack
                                            session:(DIMClientSession *)session;

@end

@interface DIMTerminal (State)

- (DIMClientMessenger *)connectToHost:(NSString *)ip port:(UInt16)port;

- (BOOL)loginWithID:(id<MKMID>)user;

- (void)keepOnlineForID:(id<MKMID>)user;

- (void)enterBackground;

- (void)enterForeground;

- (void)start;

@end

NS_ASSUME_NONNULL_END
