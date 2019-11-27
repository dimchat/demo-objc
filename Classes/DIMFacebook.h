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
//  DIMFacebook.h
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMMetaForID(ID)         [[DIMFacebook sharedInstance] metaForID:(ID)]
#define DIMProfileForID(ID)      [[DIMFacebook sharedInstance] profileForID:(ID)]

#define DIMIDWithAddress(addr)   [[DIMFacebook sharedInstance] IDWithAddress:(addr)]
#define DIMIDWithString(ID)      [[DIMFacebook sharedInstance] IDWithString:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@protocol DIMSocialNetworkDatabase;

@interface DIMFacebook : DIMBarrack

@property (weak, nonatomic, nullable) id<DIMSocialNetworkDatabase> database;

+ (instancetype)sharedInstance;

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address;

@end

@interface DIMFacebook (Storage)

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID;
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user;
- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group;

@end

@interface DIMFacebook (Relationship)

- (BOOL)user:(DIMUser *)user hasContact:(DIMID *)contact;
- (BOOL)user:(DIMUser *)user addContact:(DIMID *)contact;
- (BOOL)user:(DIMUser *)user removeContact:(DIMID *)contact;

- (BOOL)group:(DIMGroup *)group addMember:(DIMID *)member;
- (BOOL)group:(DIMGroup *)group removeMember:(DIMID *)member;

/**
 *  Get group assistants
 *
 * @param group - group ID
 * @return owner ID
 */
- (nullable NSArray<DIMID *> *)assistantsOfGroup:(DIMID *)group;

@end

NS_ASSUME_NONNULL_END
