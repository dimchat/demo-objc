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
//  DIMFacebook+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMMetaForID(ID)         [[DIMFacebook sharedInstance] metaForID:(ID)]
#define DIMProfileForID(ID)      [[DIMFacebook sharedInstance] profileForID:(ID)]

#define DIMIDWithAddress(addr)   [[DIMFacebook sharedInstance] IDWithAddress:(addr)]
#define DIMIDWithString(ID)      [[DIMFacebook sharedInstance] IDWithString:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@interface DIMFacebook (Extension)

+ (instancetype)sharedInstance;

- (void)setCurrentUser:(DIMUser *)user;

- (BOOL)saveUsers:(NSArray<DIMID *> *)list;

- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID;

//
//  contacts
//
- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID;
- (BOOL)user:(DIMID *)user addContact:(DIMID *)contact;
- (BOOL)user:(DIMID *)user removeContact:(DIMID *)contact;

//
//  group members
//
- (BOOL)group:(DIMID *)group addMember:(DIMID *)member;
- (BOOL)group:(DIMID *)group removeMember:(DIMID *)member;

@end

NS_ASSUME_NONNULL_END
