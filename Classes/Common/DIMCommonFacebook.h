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
//  DIMCommonFacebook.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import <DIMP/DIMAccountDBI.h>
#import <DIMP/DIMAddressNameServer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Common Facebook with Database
 */
@interface DIMCommonFacebook : DIMFacebook

@property(nonatomic, readonly) id<DIMAccountDBI> database;

@property(nonatomic, strong, nullable) id<MKMUser> currentUser;  // 1st local user

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)db
NS_DESIGNATED_INITIALIZER;

/**
 *  Save members of group
 *
 * @param bots - assistant ID list
 * @param ID - group ID
 * @return true on success
 */
- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)ID;

@end

NS_ASSUME_NONNULL_END
