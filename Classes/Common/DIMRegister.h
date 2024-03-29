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
//  DIMRegister.h
//  DIMClient
//
//  Created by Albert Moky on 2019/12/20.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMClient/DIMAccountDBI.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMRegister : NSObject

@property (strong, nonatomic, readonly) id<DIMAccountDBI> database;

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)db
NS_DESIGNATED_INITIALIZER;

/**
 *  Generate user account
 *
 * @param nickname - user name
 * @param url - avatar URL
 * @return User ID
 */
- (id<MKMID>)createUserWithName:(NSString *)nickname
                         avatar:(nullable id<MKMPortableNetworkFile>)url;

/**
 *  Generate group account (Polylogue)
 *
 * @param name - group title
 * @param ID - group founder
 * @return Group ID
 */
- (id<MKMID>)createGroupWithName:(NSString *)name founder:(id<MKMID>)ID;
- (id<MKMID>)createGroupWithName:(NSString *)name
                            seed:(NSString *)seed founder:(id<MKMID>)ID;

@end

@interface DIMRegister (Plugins)

// load plugins
+ (void)prepare;

@end

NS_ASSUME_NONNULL_END
