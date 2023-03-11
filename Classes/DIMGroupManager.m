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
//  DIMP
//
//  Created by Albert Moky on 2020/4/5.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMGroupManager.h"

@interface DIMGroupManager ()

@property(nonatomic, strong) id<MKMID> group;

@property(nonatomic, strong) DIMClientMessenger *messenger;

@end

@implementation DIMGroupManager

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    id<MKMID> ID = nil;
    DIMClientMessenger *transceiver = nil;
    return [self initWithGroupID:ID messenger:transceiver];
}

/* designated initializer */
- (instancetype)initWithGroupID:(id<MKMID>)ID
                      messenger:(DIMClientMessenger *)transceiver {
    if (self = [super init]) {
        self.group = ID;
        self.messenger = transceiver;
    }
    return self;
}

- (BOOL)sendContent:(id<DKDContent>)content {
    // check group ID
    id<MKMID> group = [content group];
    if (group) {
        NSAssert([group isEqual:_group], @"group ID not match: %@, %@", _group, content);
    } else {
        group = _group;
        [content setGroup:group];
    }
    DIMCommonFacebook *facebook = [_messenger facebook];
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:group];
    OKPair<id<DKDInstantMessage>, id<DKDReliableMessage>> *results;
    for (id<MKMID> bot in assistants) {
        // send to any bot
        results = [_messenger sendContent:content
                                   sender:nil
                                 receiver:bot
                                 priority:0];
        if (results.second != nil) {
            // only send to one bot, let the bot to split and
            // forward this message to all members
            return YES;
        }
    }
    return NO;
}

- (void)sendCommand:(id<DKDCommand>)content receiver:(id<MKMID>)to {
    NSAssert(to, @"receiver should not be empty");
    [_messenger sendContent:content sender:nil receiver:to priority:0];
}

- (void)sendCommand:(id<DKDCommand>)content members:(NSArray<id<MKMID>> *)members {
    NSAssert([members count] > 0, @"receivers should not be empty");
    for (id<MKMID> item in members) {
        [self sendCommand:content receiver:item];
    }
}

- (BOOL)inviteMember:(id<MKMID>)member {
    return [self inviteMembers:@[member]];
}

- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)newMembers {
    DIMCommonFacebook *facebook = [_messenger facebook];
    NSArray<id<MKMID>> *bots = [facebook assistantsOfGroup:_group];
    
    // TODO: make sure group meta exists
    // TODO: make sure current user is a member

    // 0. build 'meta/document' command
    id<MKMMeta> meta = [facebook metaForID:_group];
    if (!meta) {
        NSAssert(false, @"failed to get meta for group: %@", _group);
        return NO;
    }
    id<MKMDocument> doc = [facebook documentForID:_group type:@"*"];
    id<DKDCommand> command;
    if (doc) {
        command = [[DIMDocumentCommand alloc] initWithID:_group
                                                    meta:meta
                                                document:doc];
    } else {
        // empty document
        command = [[DIMMetaCommand alloc] initWithID:_group
                                                meta:meta];
    }
    // 1. send 'meta/document' command
    [self sendCommand:command members:bots];            // to all assistants
    
    // 2. update local members and notice all bots & members
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:_group];
    if ([members count] <= 2) { // new group?
        // 2.0. update local storage
        members = [self addMembers:newMembers];
        // 2.1. send 'meta/document' command
        [self sendCommand:command members:members];     // to all members
        // 2.2. send 'invite' command with all members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:_group
                                                       members:members];
        [self sendCommand:command members:bots];        // to group assistants
        [self sendCommand:command members:members];     // to all members
    } else {
        // 2.1. send 'meta/document' command
        //[self sendCommand:command members:members];   // to old members
        [self sendCommand:command members:newMembers];  // to new members
        // 2.2. send 'invite' command with new members only
        command = [[DIMInviteGroupCommand alloc] initWithGroup:_group
                                                       members:newMembers];
        [self sendCommand:command members:bots];        // to group assistants
        [self sendCommand:command members:members];     // to old members
        // 2.3. update local storage
        members = [self addMembers:newMembers];
        // 2.4. send 'invite' command with all members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:_group
                                                       members:members];
        [self sendCommand:command members:newMembers];  // to new members
    }
    
    return YES;
}

- (BOOL)expelMember:(id<MKMID>)member {
    return [self expelMembers:@[member]];
}

- (BOOL)expelMembers:(NSArray<id<MKMID>> *)outMembers {
    DIMCommonFacebook *facebook = [_messenger facebook];
    id<MKMID> owner = [facebook ownerOfGroup:_group];
    NSArray<id<MKMID>> *bots = [facebook assistantsOfGroup:_group];

    // TODO: make sure group meta exists
    // TODO: make sure current user is the owner

    // 0. check permission
    for (id<MKMID> assistant in bots) {
        if ([outMembers containsObject:assistant]) {
            NSAssert(false, @"Cannot expel group assistant: %@", assistant);
            return NO;
        }
    }
    if ([outMembers containsObject:owner]) {
        NSAssert(false, @"Cannot expel group owner: %@", owner);
        return NO;
    }
    
    // 1. update local storage
    NSArray<id<MKMID>> *members = [self removeMembers:outMembers];
    
    id<DKDCommand> command;
    // 2. send 'expel' command
    command = [[DIMExpelGroupCommand alloc] initWithGroup:_group
                                                  members:outMembers];
    [self sendCommand:command members:bots];        // to assistants
    [self sendCommand:command members:members];     // to new members
    [self sendCommand:command members:outMembers];  // to expelled members

    return YES;
}

- (BOOL)quitGroup {
    DIMCommonFacebook *facebook = [_messenger facebook];
    id<MKMID> owner = [facebook ownerOfGroup:_group];
    NSArray<id<MKMID>> *bots = [facebook assistantsOfGroup:_group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:_group];
    id<MKMUser> user = [facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = user.ID;
    
    // 0. check permission
    if ([bots containsObject:me]) {
        NSAssert(false, @"group assistant cannot quilt: %@, %@", me, _group);
        return NO;
    } else if ([me isEqual:owner]) {
        NSAssert(false, @"group owner cannot quilt: %@, %@", me, _group);
        return NO;
    }
    
    // 1. update local storage
    if ([members containsObject:me]) {
        NSMutableArray *mArray = [members mutableCopy];
        [mArray removeObject:me];
        [facebook saveMembers:mArray group:_group];
    //} else {
    //    // not a member now
    //    return NO;
    }
    
    id<DKDCommand> command;
    // 2. send 'quit' command
    command = [[DIMQuitGroupCommand alloc] initWithGroup:_group];
    [self sendCommand:command members:bots];     // to assistants
    [self sendCommand:command members:members];  // to new members

    return YES;
}

- (BOOL)queryGroup {
    return [_messenger queryMembersForID:_group];
}

#pragma mark Local storage

- (NSArray<id<MKMID>> *)addMembers:(NSArray<id<MKMID>> *)newMembers {
    DIMCommonFacebook *facebook = [_messenger facebook];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:_group];
    NSMutableArray *mArray;
    if (members) {
        mArray = [members mutableCopy];
    } else {
        mArray = [[NSMutableArray alloc] initWithCapacity:newMembers.count];
    }
    BOOL count = 0;
    for (id<MKMID> ID in newMembers) {
        if ([mArray containsObject:ID]) {
            NSLog(@"member %@ already exists, group: %@", ID, _group);
        } else {
            [mArray addObject:ID];
            ++count;
        }
    }
    if (count > 0) {
        [facebook saveMembers:mArray group:_group];
    }
    return mArray;
}

- (NSArray<id<MKMID>> *)removeMembers:(NSArray<id<MKMID>> *)outMembers {
    DIMCommonFacebook *facebook = [_messenger facebook];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:_group];
    NSMutableArray *mArray = [members mutableCopy];
    NSAssert(mArray, @"failed to get members for group: %@", _group);
    
    BOOL count = 0;
    for (id<MKMID> ID in outMembers) {
        if ([mArray containsObject:ID]) {
            [mArray removeObject:ID];
            ++count;
        } else {
            NSLog(@"member %@ not exists, group: %@", ID, _group);
            continue;
        }
    }
    if (count > 0) {
        [facebook saveMembers:mArray group:_group];
    }
    return mArray;
}

@end
