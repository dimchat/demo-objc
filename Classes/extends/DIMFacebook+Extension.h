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
#define DIMDocumentForID(ID, DT) [[DIMFacebook sharedInstance] documentForID:(ID) type:(DT)]
#define DIMVisaForID(ID)         DIMDocumentForID(ID, MKMDocument_Visa)

#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

#define DIMPrivateKeyType_Visa   @"visa"
#define DIMPrivateKeyType_Meta   @"meta"

@interface DIMFacebook (Extension)

+ (instancetype)sharedInstance;

- (void)setCurrentUser:(DIMUser *)user;

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list;

/**
 *  Save private key for user with key type
 *
 * @param key - private key
 * @param type - "visa" or "meta"
 * @param ID - user ID
 * @return NO on failed
 */
- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key type:(NSString *)type user:(id<MKMID>)ID;

//
//  contacts
//
- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)ID;
- (BOOL)user:(id<MKMID>)user addContact:(id<MKMID>)contact;
- (BOOL)user:(id<MKMID>)user removeContact:(id<MKMID>)contact;

//
//  group members
//
- (BOOL)group:(id<MKMID>)group addMember:(id<MKMID>)member;
- (BOOL)group:(id<MKMID>)group removeMember:(id<MKMID>)member;

- (BOOL)group:(id<MKMID>)group containsMember:(id<MKMID>)member;
- (BOOL)group:(id<MKMID>)group containsAssistant:(id<MKMID>)assistant;

@end

NS_ASSUME_NONNULL_END
