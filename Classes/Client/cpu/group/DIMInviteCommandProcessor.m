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
//  DIMInviteCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMCommonFacebook.h"

#import "DIMInviteCommandProcessor.h"

@implementation DIMInviteGroupCommandProcessor

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDInviteGroupCommand)],
             @"invite command error: %@", content);
    id<DKDGroupCommand> command = content;
    
    // 0. check command
    DIMCommandExpiredResults *pair = [self checkCommandExpired:command
                                                       message:rMsg];
    id<MKMID> group = [pair first];
    if (!group) {
        // ignore expired command
        return [pair second];
    }
    DIMCommandMembersResults *pair1 = [self checkCommandMembers:command
                                                        message:rMsg];
    DIMIDList *inviteList = [pair1 first];
    if ([inviteList count] == 0) {
        // command error
        return [pair second];
    }
    
    // 1. check group
    DIMGroupMembersResults *trip = [self checkGroupMembers:command
                                                   message:rMsg];
    id<MKMID> owner = [trip first];
    DIMIDList *members = [trip second];
    if (!owner || [members count] == 0) {
        return [trip third];
    }
    
    id<MKMID> sender = [rMsg sender];
    DIMIDList *admins = [self administratorsOfGroup:group];
    BOOL isOwner = [owner isEqual:sender];
    BOOL isAdmin = [admins containsObject:sender];
    BOOL isMember = [members containsObject:sender];
    
    // 2. check permission
    if (!isMember) {
        NSDictionary *info = @{
            @"template": @"Not allowed to invite member into group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    BOOL canReset = isOwner || isAdmin;
    
    // 3. do invite
    OKPair<DIMIDList *, DIMIDList *> *memPair = [self calculateInvited:inviteList
                                                               members:members];
    DIMIDList *newMembers = [memPair first];
    DIMIDList *addedList = [memPair second];
    if ([addedList count] == 0) {
        // maybe those users are already become members,
        // but if it can still receive an 'invite' command here,
        // we should respond the sender with the newest membership again.
        DIMCommonFacebook *facebook = [self facebook];
        id<MKMUser> user = [facebook currentUser];
        if (!canReset || [user.ID isEqual:owner]) {
            // the sender cannot reset the group, means it's an ordinary member now,
            // and if I am the owner, then send the group history commands
            // to update the sender's memory.
            BOOL ok = [self sendHistoriesTo:sender group:group];
            if (!ok) {
                NSAssert(false, @"failed to send history for group: %@ => %@", group, sender);
            }
        }
    } else if (![self saveHistory:command withMessage:rMsg group:group]) {
        // here try to append the 'invite' command to local storage as group history
        // it should not failed unless the command is expired
        NSLog(@"failed to save 'invite' command for group: %@", group);
    } else if (!canReset) {
        // the sender cannot reset the group, means it's invited by ordinary member,
        // and the 'invite' command was saved, now waiting for review.
    } else if ([self saveMembers:newMembers group:group]) {
        // FIXME: this sender has permission to reset the group,
        //        means it must be the owner or an administrator,
        //        usually it should send a 'reset' command instead;
        //        if we received the 'invite' command here, maybe it was confused,
        //        anyway, we just append the new members directly.
        NSLog(@"invited by administrator: %@, group: %@", sender, group);
        [command setObject:MKMIDRevert(addedList) forKey:@"added"];
    } else {
        // DB error:
        NSAssert(false, @"failed to save members for group: %@", group);
    }
    
    // no need to response this group command
    return nil;
}

// protected
- (OKPair<DIMIDList *, DIMIDList *> *)calculateInvited:(DIMIDList *)inviteList
                                               members:(DIMIDList *)members {
    NSMutableArray<id<MKMID>> *newMembers;
    if (members) {
        newMembers = [members mutableCopy];
    } else {
        newMembers = [[NSMutableArray alloc] init];
    }
    NSMutableArray<id<MKMID>> *addedList = [[NSMutableArray alloc] init];
    for (id<MKMID> item in inviteList) {
        if ([newMembers containsObject:item]) {
            continue;
        }
        [newMembers addObject:item];
        [addedList addObject:item];
    }
    return [[OKPair alloc] initWithFirst:newMembers second:addedList];
}

@end
