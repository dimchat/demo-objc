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

@protocol DIMAddressNameService;

@interface DIMFacebook : DIMBarrack

@property (weak, nonatomic) id<DIMAddressNameService> ans;

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address;

@end

@interface DIMFacebook (Storage)

#pragma mark Meta

- (BOOL)verifyMeta:(DIMMeta *)meta forID:(DIMID *)ID;

/**
 *  Save meta for entity ID (must verify first)
 *
 * @param meta - entity meta
 * @param ID - entity ID
 * @return true on success
 */
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;

/**
 *  Load meta for entity ID
 *
 * @param ID - entity ID
 * @return Meta object on success
 */
- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID;

#pragma mark Profile

- (BOOL)verifyProfile:(DIMProfile *)profile forID:(DIMID *)ID;
- (BOOL)verifyProfile:(DIMProfile *)profile;

- (BOOL)cacheProfile:(DIMProfile *)profile forID:(DIMID *)ID;
- (BOOL)cacheProfile:(DIMProfile *)profile;

/**
 *  Save profile with entity ID (must verify first)
 *
 * @param profile - entity profile
 * @return true on success
 */
- (BOOL)saveProfile:(DIMProfile *)profile;

/**
 *  Load profile for entity ID
 *
 * @param ID - entity ID
 * @return Profile object on success
 */
- (nullable DIMProfile *)loadProfileForID:(DIMID *)ID;

#pragma mark Private Key

- (BOOL)cachePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID;

/**
 *  Save private key for user ID
 *
 * @param key - private key
 * @param ID - user ID
 * @return true on success
 */
- (BOOL)savePrivateKey:(DIMPrivateKey *)key user:(DIMID *)ID;

/**
 *  Load private key for user ID
 *
 * @param ID - user ID
 * @return PrivateKey object on success
 */
- (nullable DIMPrivateKey *)loadPrivateKey:(DIMID *)ID;

#pragma mark User Contacts

- (BOOL)cacheContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID;

/**
 *  Save contacts for user
 *
 * @param contacts - contact ID list
 * @param ID - user ID
 * @return true on success
 */
- (BOOL)saveContacts:(NSArray<DIMID *> *)contacts user:(DIMID *)ID;

/**
 *  Load contacts for user
 *
 * @param ID - user ID
 * @return contact ID list on success
 */
- (nullable NSArray<DIMID *> *)loadContacts:(DIMID *)ID;

#pragma mark Group Members

- (BOOL)cacheMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID;

/**
 *  Save members of group
 *
 * @param members - member ID list
 * @param ID - group ID
 * @return true on success
 */
- (BOOL)saveMembers:(NSArray<DIMID *> *)members group:(DIMID *)ID;

/**
 *  Load members of group
 *
 * @param ID - group ID
 * @return member ID list on success
 */
- (nullable NSArray<DIMID *> *)loadMembers:(DIMID *)ID;

@end

@interface DIMFacebook (Relationship)

- (BOOL)user:(DIMID *)user hasContact:(DIMID *)contact;
- (BOOL)user:(DIMID *)user addContact:(DIMID *)contact;
- (BOOL)user:(DIMID *)user removeContact:(DIMID *)contact;

- (BOOL)group:(DIMID *)group isFounder:(DIMID *)member;
- (BOOL)group:(DIMID *)group isOwner:(DIMID *)member;

- (BOOL)group:(DIMID *)group hasMember:(DIMID *)member;
- (BOOL)group:(DIMID *)group addMember:(DIMID *)member;
- (BOOL)group:(DIMID *)group removeMember:(DIMID *)member;

#pragma mark Assistant

- (nullable NSArray<DIMID *> *)assistantsOfGroup:(DIMID *)group;
- (BOOL)group:(DIMID *)group hasAssistant:(DIMID *)assistant;

@end

NS_ASSUME_NONNULL_END
