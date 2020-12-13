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
//  DIMSocialNetworkDatabase.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMSocialNetworkDatabase : NSObject <MKMUserDataSource, MKMGroupDataSource>

// Address Name Service
- (BOOL)saveANSRecord:(id<MKMID>)ID forName:(NSString *)name;
- (id<MKMID>)ansRecordForName:(NSString *)name;
- (NSArray<NSString *> *)namesWithANSRecord:(NSString *)ID;

- (nullable NSArray<id<MKMID>> *)allUsers;
- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list;
- (BOOL)saveUser:(id<MKMID>)user;
- (BOOL)removeUser:(id<MKMID>)user;

- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key type:(NSString *)type forID:(id<MKMID>)ID;
- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID;
- (BOOL)saveDocument:(id<MKMDocument>)profile;

- (BOOL)saveContacts:(NSArray *)contacts user:(id<MKMID>)user;
- (BOOL)saveMembers:(NSArray *)members group:(id<MKMID>)group;

@end

NS_ASSUME_NONNULL_END
