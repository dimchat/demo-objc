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
//  DIMMessageDBI.h
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>
#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

// partial messages and remaining count, 0 means there are all messages cached
typedef OKPair<NSArray<id<DKDReliableMessage>> *, NSNumber *> DIMReliableMessageResult;

@protocol DIMReliableMessageDBI <NSObject>

/*
 *  Get network messages
 *
 * @param receiver - actual receiver
 * @param range    - (start, length) for loading message
 * @return message result
 */
- (DIMReliableMessageResult *)reliableMessageForReceiver:(id<MKMID>)receiver
                                                   range:(NSRange)range;

- (BOOL)cacheReliableMessage:(id<DKDReliableMessage>)rMsg
                 forReceiver:(id<MKMID>)receiver;

- (BOOL)removeReliableMessage:(id<DKDReliableMessage>)rMsg
                  forReceiver:(id<MKMID>)receiver;

@end

@protocol DIMCipherKeyDBI <DIMCipherKeyDelegate>

@end

@protocol DIMMessageDBI <DIMReliableMessageDBI, DIMCipherKeyDBI>

@end

NS_ASSUME_NONNULL_END
