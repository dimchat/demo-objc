// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  DIMConversation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMClient/DIMConversationDatabase.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMConversationID) {
    DIMConversationUnknown  = 0x00,
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef UInt8 DIMConversationType;

@interface DIMConversation : NSObject

@property (readonly, nonatomic) DIMConversationType type; // Network ID

@property (readonly, strong, nonatomic) id<MKMID> ID;
@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic, nullable) __kindof id<MKMDocument> document;

@property (weak, nonatomic) id<DIMConversationDataSource> dataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

- (instancetype)initWithEntity:(id<DIMEntity>)entity
NS_DESIGNATED_INITIALIZER;

#pragma mark - Read

/**
 *  Get message count
 *
 * @return total count
 */
- (NSInteger)numberOfMessage;

/**
 *  Get message at index
 *
 * @param index - start from 0, latest first
 * @return instant message
 */
- (id<DKDInstantMessage>)messageAtIndex:(NSInteger)index;

#pragma mark - Write

/**
 *  Insert a new message
 *
 * @param iMsg - instant message
 */
- (BOOL)insertMessage:(id<DKDInstantMessage>)iMsg;

/**
 *  Delete the message
 *
 * @param iMsg - instant message
 */
- (BOOL)removeMessage:(id<DKDInstantMessage>)iMsg;

/**
 *  Try to withdraw the message
 *
 * @param iMsg - instant message
 */
- (BOOL)withdrawMessage:(id<DKDInstantMessage>)iMsg;

@end

NS_ASSUME_NONNULL_END
