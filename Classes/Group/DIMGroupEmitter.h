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
//  DIMGroupEmitter.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

// NOTICE: group assistants (bots) can help the members to redirect messages
//
//      if members.length < POLYLOGUE_LIMIT,
//          means it is a small polylogue group, let the members to split
//          and send group messages by themselves, this can keep the group
//          more secretive because no one else can know the group ID even;
//      else,
//          set 'assistants' in the bulletin document to tell all members
//          that they can let the group bot to do the job for them.
//
#define DIM_POLYLOGUE_LIMIT    32

// NOTICE: expose group ID to reduce encrypting time
//
//      if members.length < SECRET_GROUP_LIMIT,
//          means it is a tiny group, you can choose to hide the group ID,
//          that you can split and encrypt message one by one;
//      else,
//          you should expose group ID in the instant message level, then
//          encrypt message by one symmetric key for this group, after that,
//          split and send to all members directly.
//
#define DIM_SECRET_GROUP_LIMIT 16

@class DIMGroupDelegate;
@class DIMGroupPacker;

@class DIMCommonFacebook;
@class DIMCommonMessenger;

@interface DIMGroupEmitter : NSObject

@property (strong, nonatomic, readonly) DIMGroupDelegate *delegate;
@property (strong, nonatomic, readonly) DIMGroupPacker *packer;

// protected, override for customized packer
- (DIMGroupPacker *)createPacker;

@property (strong, nonatomic, readonly) __kindof DIMCommonFacebook *facebook;
@property (strong, nonatomic, readonly) __kindof DIMCommonMessenger *messenger;

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate;

- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior;

@end

NS_ASSUME_NONNULL_END
