// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
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
//  DIMGroupManager.h
//  DIMClient
//
//  Created by Albert Moky on 2020/4/5.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DIMClient/DIMClientMessenger.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupManager : NSObject <MKMGroupDataSource>

@property(nonatomic, strong) __kindof DIMClientMessenger *messenger;

+ (instancetype)sharedInstance;

/**
 *  Send message content to this group
 *  (only existed member can do this)
 *
 * @param content - message content
 * @param gid - group ID
 * @return YES on success
*/
- (BOOL)sendContent:(id<DKDContent>)content group:(id<MKMID>)gid;

/**
 *  Invite new members to this group
 *  (only existed member/assistant can do this)
 *
 * @param newMembers - new members ID list
 * @param gid - group ID
 * @return YES on success
*/
- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid;
- (BOOL)inviteMember:(id<MKMID>)member group:(id<MKMID>)gid;

/**
 *  Expel members from this group
 *  (only group owner/assistant can do this)
 *
 * @param outMembers - existed member ID list
 * @param gid - group ID
 * @return YES on success
*/
- (BOOL)expelMembers:(NSArray<id<MKMID>> *)outMembers group:(id<MKMID>)gid;
- (BOOL)expelMember:(id<MKMID>)member group:(id<MKMID>)gid;

/**
 *  Quit from this group
 *  (only group member can do this)
 *
 * @param gid - group ID
 * @return YES on success
 */
- (BOOL)quitGroup:(id<MKMID>)gid;

/**
 *  Query group info
 *  (only group member can do this)
 *
 * @param gid - group ID
 * @return YES on success
 */
- (BOOL)queryGroup:(id<MKMID>)gid;

@end

@interface DIMGroupManager (MemberShip)

- (BOOL)isFounder:(id<MKMID>)member group:(id<MKMID>)gid;
- (BOOL)isOwner:(id<MKMID>)member group:(id<MKMID>)gid;

//
//  members
//

- (BOOL)containsMember:(id<MKMID>)uid group:(id<MKMID>)gid;
- (BOOL)addMember:(id<MKMID>)uid group:(id<MKMID>)gid;
- (BOOL)removeMember:(id<MKMID>)uid group:(id<MKMID>)gid;

// private
- (NSArray<id<MKMID>> *)addMembers:(NSArray<id<MKMID>> *)newMembers
                             group:(id<MKMID>)gid;
// private
- (NSArray<id<MKMID>> *)removeMembers:(NSArray<id<MKMID>> *)outMembers
                                group:(id<MKMID>)gid;

/**
 *  Save members of group
 *
 * @param members - member ID list
 * @param gid - group ID
 * @return true on success
 */
- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

//
//  assistants
//

- (BOOL)containsAssistant:(id<MKMID>)bot group:(id<MKMID>)gid;
- (BOOL)addAssistant:(id<MKMID>)bot group:(nullable id<MKMID>)gid;

/**
 *  Save members of group
 *
 * @param bots - assistant ID list
 * @param gid - group ID
 * @return true on success
 */
- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)gid;

/**
 *  Remove group completely
 *
 * @param gid - group ID
 * @return true on success
 */
- (BOOL)removeGroup:(id<MKMID>)gid;

@end

NS_ASSUME_NONNULL_END
