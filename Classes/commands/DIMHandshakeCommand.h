// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMHandshakeCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Handshake @"handshake"

typedef NS_ENUM(UInt8, DIMHandshakeState) {
    DIMHandshake_Init,
    DIMHandshake_Start,   // C -> S, without session key(or session expired)
    DIMHandshake_Again,   // S -> C, with new session key
    DIMHandshake_Restart, // C -> S, with new session key
    DIMHandshake_Success, // S -> C, handshake accepted
};

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      cmd     : "handshake",    // command name
 *      message : "Hello world!",
 *      session : "{SESSION_KEY}" // session key
 *  }
 */
@protocol DKDHandshakeCommand <DKDCommand>

@property (readonly, strong, nonatomic) NSString *message;
@property (readonly, strong, nonatomic, nullable) NSString *sessionKey;

@property (readonly, nonatomic) DIMHandshakeState state;

@end

@interface DIMHandshakeCommand : DIMCommand <DKDHandshakeCommand>

- (instancetype)initWithMessage:(NSString *)message
                     sessionKey:(nullable NSString *)session;

- (instancetype)initWithSessionKey:(nullable NSString *)session;

@end

NS_ASSUME_NONNULL_END
