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
//  DIMGroupPacker.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMGroupDelegate;

@interface DIMGroupPacker : NSObject

@property (strong, nonatomic, readonly) DIMGroupDelegate *delegate;

@property (strong, nonatomic, readonly) __kindof DIMMessenger *messenger;

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate;

/**
 *  Pack as broadcast message
 */
- (id<DKDReliableMessage>)packMessageWithContent:(id<DKDContent>)content
                                          sender:(id<MKMID>)from;

- (id<DKDReliableMessage>)encryptAndSignMessage:(id<DKDInstantMessage>)iMsg;

- (NSArray<id<DKDInstantMessage>> *)splitInstantMessage:(id<DKDInstantMessage>)iMsg
                                                members:(NSArray<id<MKMID>> *)members;

- (NSArray<id<DKDReliableMessage>> *)splitReliableMessage:(id<DKDReliableMessage>)rMsg
                                                  members:(NSArray<id<MKMID>> *)members;

@end

NS_ASSUME_NONNULL_END
