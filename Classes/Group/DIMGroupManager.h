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

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMGroupDelegate;
@class DIMGroupPacker;

@class DIMGroupCommandHelper;
@class DIMGroupHistoryBuilder;

@class DIMCommonFacebook;
@class DIMCommonMessenger;

@protocol DIMAccountDBI;

@interface DIMGroupManager : NSObject

@property (strong, nonatomic, readonly) DIMGroupDelegate *delegate;
@property (strong, nonatomic, readonly) DIMGroupPacker *packer;

@property (strong, nonatomic, readonly) DIMGroupCommandHelper *helper;
@property (strong, nonatomic, readonly) DIMGroupHistoryBuilder *builder;

// protected, override for customized packer
- (DIMGroupPacker *)createPacker;

// protected, override for customized helper
- (DIMGroupCommandHelper *)createHelper;

// protected, override for customized builder
- (DIMGroupHistoryBuilder *)createBuilder;

@property (strong, nonatomic, readonly) __kindof DIMCommonFacebook *facebook;
@property (strong, nonatomic, readonly) __kindof DIMCommonMessenger *messenger;

@property (strong, nonatomic, readonly) id<DIMAccountDBI> database;

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate;

/**
 *  Create new group with members
 *  (broadcast document & members to all members and neighbor station)
 *
 * @param members - initial group members
 * @return new group ID
 */
- (id<MKMID>)createGroupWithMembers:(NSArray<id<MKMID>> *)members;

// DISCUSS: should we let the neighbor stations know the group info?
//      (A) if we do this, it can provide a convenience that,
//          when someone receive a message from an unknown group,
//          it can query the group info from the neighbor immediately;
//          and its potential risk is that anyone not in the group can also
//          know the group info (only the group ID, name, and admins, ...)
//      (B) but, if we don't let the station knows it,
//          then we must shared the group info with our members themselves;
//          and if none of them is online, you cannot get the newest info
//          immediately until someone online again.

/**
 *  Reset group members
 *  (broadcast new group history to all members)
 *
 * @param gid - group ID
 * @param members - new member list
 * @return false on error
 */
- (BOOL)resetMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

/**
 *  Invite new members to this group
 *
 * @param gid - group ID
 * @param members - inviting member list
 * @return false on error
 */
- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

/**
 *  Quit from this group
 *  (broadcast a 'quit' command to all members)
 *
 * @param gid - group ID
 * @return false on error
 */
- (BOOL)quitGroup:(id<MKMID>)gid;

@end

NS_ASSUME_NONNULL_END
