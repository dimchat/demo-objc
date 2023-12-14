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
//  DIMGroupManager.m
//  DIMClient
//
//  Created by Albert Moky on 2020/4/5.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMCommonFacebook.h"
#import "DIMCommonMessenger.h"

#import "DIMRegister.h"

#import "DIMGroupDelegate.h"
#import "DIMGroupPacker.h"

#import "DIMGroupCommandHelper.h"
#import "DIMGroupHistoryBuilder.h"

#import "DIMGroupManager.h"

static inline NSMutableArray *mutable_array(NSArray *array) {
    if (!array) {
        return [[NSMutableArray alloc] init];
    } else if ([array isKindOfClass:[NSMutableArray class]]) {
        return (NSMutableArray *)array;
    } else {
        return [array mutableCopy];
    }
}

typedef NSMutableArray<id<MKMID>> UserList;

@interface DIMGroupManager ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;
@property (strong, nonatomic) DIMGroupPacker *packer;

@property (strong, nonatomic) DIMGroupCommandHelper *helper;
@property (strong, nonatomic) DIMGroupHistoryBuilder *builder;

@end

@implementation DIMGroupManager

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        self.packer = [self createPacker];
        self.helper = [self createHelper];
        self.builder = [self createBuilder];
    }
    return self;
}

- (DIMGroupPacker *)createPacker {
    return [[DIMGroupPacker alloc] initWithDelegate:self.delegate];
}

- (DIMGroupCommandHelper *)createHelper {
    return [[DIMGroupCommandHelper alloc] initWithDelegate:self.delegate];
}

- (DIMGroupHistoryBuilder *)createBuilder {
    return [[DIMGroupHistoryBuilder alloc] initWithDelegate:self.delegate];
}

- (DIMCommonFacebook *)facebook {
    return [self.delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    return [self.delegate messenger];
}

- (id<MKMID>)createGroupWithMembers:(NSArray<id<MKMID>> *)members {
    NSAssert([members count] > 1, @"not enough members: %@", members);
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return nil;
    }
    id<MKMID> founder = [user ID];

    //
    //  1. check founder (owner)
    //
    NSUInteger pos = [members indexOfObject:founder];
    if (pos == NSNotFound) {
        // put me in the first position
        NSMutableArray *mArray = mutable_array(members);
        [mArray insertObject:founder atIndex:0];
        members = mArray;
    } else if (pos > 0) {
        // move me to the front
        NSMutableArray *mArray = mutable_array(members);
        [mArray removeObjectAtIndex:pos];
        [mArray insertObject:founder atIndex:0];
        members = mArray;
    }
    NSString *groupName = [self.delegate buildGroupNameWithMembers:members];
    
    //
    //  2. create group with name
    //
    DIMRegister *agent = [[DIMRegister alloc] initWithDatabase:self.database];
    id<MKMID> group = [agent createGroupWithName:groupName founder:founder];
    NSLog(@"new group: %@ (%@), founder: %@", group, groupName, founder);
    
    //
    //  3. upload meta+document to neighbor station(s)
    //  DISCUSS: should we let the neighbor stations know the group info?
    //
    id<MKMMeta> meta = [self.delegate metaForID:group];
    id<MKMBulletin> doc = [self.delegate bulletinForID:group];
    id<DKDCommand> content;
    if (doc) {
        content = DIMDocumentCommandResponse(group, meta, doc);
    } else if (meta) {
        content = DIMMetaCommandResponse(group, meta);
    } else {
        NSAssert(false, @"failed to get group info: %@", group);
        return nil;
    }
    BOOL ok = [self sendCommand:content receiver:MKMAnyStation()];  // to neighbor(s)
    NSAssert(ok, @"failed to upload meta/document to neighbor station");
    
    //
    //  4. create & broadcast 'reset' group command with new members
    //
    if ([self resetMembers:members group:group]) {
        NSLog(@"create group %@ with %lu members", group, members.count);
    } else {
        NSLog(@"failed to create group %@ with %lu members", group, members.count);
    }
    
    return group;
}

- (BOOL)resetMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid {
    NSAssert([gid isGroup] && [newMembers count] > 0, @"params error: %@, %@", gid, newMembers);
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    
    // check member list
    id<MKMID> first = [newMembers firstObject];
    BOOL ok = [self.delegate isOwner:first group:gid];
    if (!ok) {
        NSAssert(false, @"group owner must be the first member: %@", gid);
        return NO;
    }
    // member list OK, check expelled members
    NSArray<id<MKMID>> *oldMembers = [self.delegate membersOfGroup:gid];
    NSMutableArray<id<MKMID>> *expelList = [[NSMutableArray alloc] initWithCapacity:oldMembers.count];
    for (id<MKMID> item in oldMembers) {
        if (![newMembers containsObject:item]) {
            [expelList addObject:item];
        }
    }
    
    //
    //  1. check permission
    //
    BOOL isOwner = [me isEqual:first];
    BOOL isAdmin = [self.delegate isAdministrator:me group:gid];
    BOOL isBot = [self.delegate isAssistant:me group:gid];
    BOOL canReset = isOwner || isAdmin;
    if (!canReset) {
        NSAssert(false, @"cannot reset members of group: %@", gid);
        return NO;
    }
    // only the owner or admin can reset group members
    NSAssert(!isBot, @"group bot cannot reset members: %@, %@", gid, me);
    
    //
    //  2. build 'reset' command
    //
    DIMResetCmdMsg *pair = [self.builder buildResetCommandForGroup:gid members:newMembers];
    id<DKDResetGroupCommand> reset = [pair first];
    id<DKDReliableMessage> rMsg = [pair second];
    if (!reset || !rMsg) {
        NSAssert(false, @"failed to build 'reset' command for group: %@", gid);
        return NO;
    }
    
    //
    //  3. save 'reset' command, and update new members
    //
    if (![self.helper saveGroupHistory:reset message:rMsg group:gid]) {
        NSAssert(false, @"failed to save 'reset' command for group: %@", gid);
        return NO;
    } else if (![self.delegate saveMembers:newMembers group:gid]) {
        NSAssert(false, @"failed to update members of group: %@", gid);
        return NO;
    } else {
        NSLog(@"group members updated: %@, %lu", gid, newMembers.count);
    }
    
    //
    //  4. forward all group history
    //
    NSArray<id<DKDReliableMessage>> *messages = [self.builder buildHistoryForGroup:gid];
    id<DKDForwardContent> forward = DIMForwardContentCreate(messages);
    
    NSArray<id<MKMID>> *bots = [self.delegate assistantsOfGroup:gid];
    if ([bots count] > 0) {
        // let the group bots know the newest member ID list,
        // so they can split group message correctly for us.
        return [self sendCommand:forward members:bots];         // to all assistants
    } else {
        // group bots not exist,
        // send the command to all members
        [self sendCommand:forward members:newMembers];          // to new members
        [self sendCommand:forward members:expelList];           // to removed members
    }
    
    return YES;
}

- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid {
    NSAssert([gid isGroup] && [newMembers count] > 0, @"params error: %@, %@", gid, newMembers);
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    
    NSArray<id<MKMID>> *oldMembers = [self.delegate membersOfGroup:gid];
    
    BOOL isOwner = [self.delegate isOwner:me group:gid];
    BOOL isAdmin = [self.delegate isAdministrator:me group:gid];
    BOOL isMember = [self.delegate isMember:me group:gid];
    
    //
    //  1. check permission
    //
    BOOL canReset = isOwner || isAdmin;
    if (canReset) {
        // You are the owner/admin, then
        // append new members and 'reset' the group
        NSMutableArray<id<MKMID>> *mArray = mutable_array(oldMembers);
        for (id<MKMID> item in newMembers) {
            if (![mArray containsObject:item]) {
                [mArray addObject:item];
            }
        }
        return [self resetMembers:mArray group:gid];
    } else if (!isMember) {
        NSAssert(false, @"cannot invite member into group: %@", gid);
        return NO;
    }
    // invited by ordinary member

    //
    //  2. build 'invite' command
    //
    id<DKDInviteGroupCommand> invite = DIMGroupCommandInvite(gid, newMembers);
    id<DKDReliableMessage> rMsg = [self.packer packMessageWithContent:invite sender:me];
    if (!rMsg) {
        NSAssert(false, @"failed to build 'invite' command for group: %@", gid);
        return NO;
    } else if (![self.helper saveGroupHistory:invite message:rMsg group:gid]) {
        NSAssert(false, @"failed to save 'invite' command for group: %@", gid);
        return NO;
    }
    id<DKDForwardContent> forward = DIMForwardContentCreate(@[rMsg]);
    
    //
    //  3. forward group command(s)
    //
    NSArray<id<MKMID>> *bots = [self.delegate assistantsOfGroup:gid];
    if ([bots count] > 0) {
        // let the group bots know the newest member ID list,
        // so they can split group message correctly for us.
        [self sendCommand:forward members:bots];            // to all assistants
    }
    
    // forward 'invite' to old members
    [self sendCommand:forward members:oldMembers];          // to old members
    
    // forward all group history to new members
    NSArray<id<DKDReliableMessage>> *messages = [self.builder buildHistoryForGroup:gid];
    forward = DIMForwardContentCreate(messages);
    
    // TODO: remove that members already exist before sending?
    [self sendCommand:forward members:newMembers];          // to new members
    return YES;
}

- (BOOL)quitGroup:(id<MKMID>)gid {
    NSAssert([gid isGroup], @"group ID error: %@", gid);
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    
    NSArray<id<MKMID>> *members = [self.delegate membersOfGroup:gid];
    NSAssert([members count] > 0, @"failed to get members for group: %@", gid);
    
    BOOL isOwner = [self.delegate isOwner:me group:gid];
    BOOL isAdmin = [self.delegate isAdministrator:me group:gid];
    BOOL isBot = [self.delegate isAssistant:me group:gid];
    BOOL isMember = [members containsObject:me];
    
    //
    //  1. check permission
    //
    if (isOwner) {
        NSAssert(false, @"owner cannot quit from group: %@", gid);
        return NO;
    } else if (isAdmin) {
        NSAssert(false, @"administrator cannot quit from group: %@", gid);
        return NO;
    }
    NSAssert(!isBot, @"group bot cannot quit: %@, %@", gid, me);
    
    //
    //  2. update local storage
    //
    if (isMember) {
        NSLog(@"quitting group: %@, %@", gid, me);
        NSMutableArray *mArray = mutable_array(members);
        [mArray removeObject:me];
        BOOL ok = [self.delegate saveMembers:mArray group:gid];
        NSAssert(ok, @"failed to save members for group: %@", gid);
    } else {
        NSLog(@"member not in group: %@, %@", gid, me);
    }
    
    //
    //  3. build 'quit' command
    //
    id<DKDCommand> content = DIMGroupCommandQuit(gid);
    id<DKDReliableMessage> rMsg = [self.packer packMessageWithContent:content sender:me];
    if (!rMsg) {
        NSAssert(false, @"failed to pack group message: %@", gid);
        return NO;
    }
    id<DKDForwardContent> forward = DIMForwardContentCreate(@[rMsg]);
    
    //
    //  4. forward 'quit' command
    //
    NSArray<id<MKMID>> *bots = [self.delegate assistantsOfGroup:gid];
    if ([bots count] > 0) {
        // let the group bots know the newest member ID list,
        // so they can split group message correctly for us.
        return [self sendCommand:forward members:bots];     // to group bots
    } else {
        // group bots not exist,
        // send the command to all members directly
        return [self sendCommand:forward members:members];  // to all members
    }
}

// private
- (BOOL)sendCommand:(id<DKDContent>)content receiver:(id<MKMID>)receiver {
    // 1. get sender
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    if ([me isEqual:receiver]) {
        NSLog(@"skip cycled message: %@ => %@", me, receiver);
        return NO;
    }
    // 2. send to receiver
    DIMCommonMessenger *messenger = [self messenger];
    DIMTransmitterResults *res;
    res = [messenger sendContent:content sender:me receiver:receiver priority:1];
    return res.second != nil;
}

// private
- (BOOL)sendCommand:(id<DKDContent>)content members:(NSArray<id<MKMID>> *)members {
    // 1. get sender
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    // 2. send to all receivers
    DIMCommonMessenger *messenger = [self messenger];
    for (id<MKMID> receiver in members) {
        if ([me isEqual:receiver]) {
            NSLog(@"skip cycled message: %@ => %@", me, receiver);
            continue;
        }
        [messenger sendContent:content sender:me receiver:receiver priority:1];
    }
    return YES;
}

@end
