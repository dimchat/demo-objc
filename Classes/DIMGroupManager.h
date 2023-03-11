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
//  DIMP
//
//  Created by Albert Moky on 2020/4/5.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DIMP/DIMClientMessenger.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupManager : NSObject

- (instancetype)initWithGroupID:(id<MKMID>)ID
                      messenger:(DIMClientMessenger *)transceiver
NS_DESIGNATED_INITIALIZER;

/**
 *  Send message content to this group
 *  (only existed member can do this)
 *
 * @param content - message content
 * @return YES on success
*/
- (BOOL)sendContent:(id<DKDContent>)content;

/**
 *  Invite new members to this group
 *  (only existed member/assistant can do this)
 *
 * @param newMembers - new members ID list
 * @return YES on success
*/
- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)newMembers;
- (BOOL)inviteMember:(id<MKMID>)member;

/**
 *  Expel members from this group
 *  (only group owner/assistant can do this)
 *
 * @param outMembers - existed member ID list
 * @return YES on success
*/
- (BOOL)expelMembers:(NSArray<id<MKMID>> *)outMembers;
- (BOOL)expelMember:(id<MKMID>)member;

/**
 *  Quit from this group
 *  (only group member can do this)
 *
 * @return YES on success
 */
- (BOOL)quitGroup;

/**
 *  Query group info
 *  (only group member can do this)
 *
 * @return YES on success
 */
- (BOOL)queryGroup;

@end

NS_ASSUME_NONNULL_END
