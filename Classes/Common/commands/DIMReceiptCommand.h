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
//  DIMReceiptCommand.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Receipt   @"receipt"

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 456,
 *
 *      command : "receipt",
 *      text    : "...",  // text message
 *      origin  : {       // original message envelope
 *          sender    : "...",
 *          receiver  : "...",
 *          time      : 0,
 *          sn        : 123,
 *          signature : "..."
 *      }
 *  }
 */
@protocol DKDReceiptCommand <DKDCommand>

@property(nonatomic, readonly, nullable) NSString *text;

// original message info
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, id> *origin;

@property(nonatomic, readonly, nullable) id<DKDEnvelope> originEnvelope;
@property(nonatomic, readonly) unsigned long originSerialNumber;
@property(nonatomic, readonly, nullable) NSString *originSignature;

- (BOOL)matchMessage:(id<DKDInstantMessage>)iMsg;

@end

@interface DIMReceiptCommand : DIMCommand <DKDReceiptCommand>

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
                              sn:(NSUInteger)num
                       signature:(nullable NSString *)sig;

- (instancetype)initWithText:(NSString *)msg;

- (instancetype)initWithText:(nullable NSString *)msg
                    envelope:(nullable id<DKDEnvelope>)env
                          sn:(NSUInteger)num
                   signature:(nullable NSString *)sig;

@end

NS_ASSUME_NONNULL_END
