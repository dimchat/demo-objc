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
//  DIMConversationDatabase+Group.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "MKMGroup+Extension.h"
#import "DIMConversationDatabase.h"

@implementation DIMConversationDatabase (GroupCommand)

- (BOOL)processQueryCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group {
    
    // 1. check permission
    if (![group existsMember:sender] &&
        ![group existsAssistant:sender]) {
        NSAssert(false, @"%@ is not a member/assistant of polylogue: %@, cannot query.", sender, group);
        return NO;
    }
    
    // 2. respond with 'invite' command
    //    NOTICE: set the subclass to do the job
    return YES;
}

- (BOOL)processResetCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group {
    
    // 0. check permission
    if (![group isOwner:sender] && ![group existsAssistant:sender]) {
        NSAssert(false, @"%@ is not the owner/assistant of polylogue: %@, cannot reset members.", sender, group);
        return NO;
    }
    
    NSArray *members = group.members;
    
    NSArray *newMembers = gCmd.members;
    if (newMembers.count > 0) {
        // replace item to ID objects
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:newMembers.count];
        for (NSString *item in newMembers) {
            [mArray addObject:DIMIDWithString(item)];
        }
        newMembers = mArray;
    }
    
    // 1. check removed member(s)
    NSMutableArray *removeds = [[NSMutableArray alloc] initWithCapacity:members.count];
    for (DIMID *item in members) {
        if ([newMembers containsObject:item]) {
            // keep this member
        } else {
            [removeds addObject:item];
        }
    }
    
    // 2. check added member(s)
    NSMutableArray *addeds = [[NSMutableArray alloc] initWithCapacity:newMembers.count];
    for (DIMID *item in newMembers) {
        if ([members containsObject:item]) {
            // member already exist
        } else {
            [addeds addObject:item];
        }
    }
    
    if (addeds.count > 0 || removeds.count > 0) {
        NSLog(@"reset group members: %@, from %@ to %@", group.ID, members, newMembers);
        
        // 3. save new members list
        if (![[DIMFacebook sharedInstance] saveMembers:newMembers group:group.ID]) {
            NSLog(@"failed to save members of group: %@", group.ID);
            return NO;
        }
    }
    
    // 4. store 'added' & 'removed' lists
    if (removeds.count > 0) {
        [gCmd setObject:removeds forKey:@"removed"];
    }
    if (addeds.count > 0) {
        [gCmd setObject:addeds forKey:@"added"];
    }
    
    return YES;
}

- (BOOL)processInviteCommand:(DIMGroupCommand *)gCmd
                   commander:(DIMID *)sender
                   polylogue:(DIMPolylogue *)group {
    
    // 0. check permission
    if (group.founder == nil && group.members.count == 0) {
        // FIXME: group profile lost?
        // FIXME: how to avoid strangers impersonating group members?
    } else if (![group isOwner:sender] &&
               ![group existsMember:sender] &&
               ![group existsAssistant:sender]) {
        NSAssert(false, @"%@ is not a member/assistant of polylogue: %@, cannot invite.", sender, group);
        return NO;
    }
    
    NSArray *members = group.members;
    
    NSMutableArray *newMembers = [[NSMutableArray alloc] initWithArray:members];
    
    NSArray *invites = gCmd.members;
    if (invites.count > 0) {
        // repace item to ID object
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:invites.count];
        for (NSString *item in invites) {
            [mArray addObject:DIMIDWithString(item)];
        }
        invites = mArray;
    }
    
    // 1. check owner(founder) for reset command
    if ([group isOwner:sender] || [group existsAssistant:sender]) {
        for (DIMID *item in invites) {
            if ([group isOwner:item]) {
                // invite owner(founder)? it means this should be a 'reset' command
                return [self processResetCommand:gCmd commander:sender polylogue:group];
            }
        }
    }
    
    // 2. check added member(s)
    NSMutableArray *addeds = [[NSMutableArray alloc] initWithCapacity:invites.count];
    for (DIMID *item in invites) {
        if ([newMembers containsObject:item]) {
            // NOTE:
            //    the owner will receive the invite command sent by itself
            //    after it's already added these members to the group,
            //    just ignore this assert.
            //NSAssert(false, @"adding member error: %@, %@", members, invites);
            //return NO;
        } else {
            [newMembers addObject:item];
            [addeds addObject:item];
        }
    }
    
    if (addeds.count > 0) {
        NSLog(@"invite members: %@ to group: %@", addeds, group.ID);
        
        // 3. save new members list
        if (![[DIMFacebook sharedInstance] saveMembers:newMembers group:group.ID]) {
            NSLog(@"failed to save members of group: %@", group.ID);
            return NO;
        }
    }
    
    // 4. stored 'added' list
    if (addeds.count > 0) {
        [gCmd setObject:addeds forKey:@"added"];
    }
    
    return YES;
}

- (BOOL)processExpelCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group {
    
    // 1. check permission
    if (![group isOwner:sender] &&
        ![group existsAssistant:sender]) {
        NSAssert(false, @"%@ is not the owner/assistant of polylogue: %@, cannot expel.", sender, group);
        return NO;
    }
    
    NSArray *members = group.members;
    
    NSMutableArray *newMembers = [[NSMutableArray alloc] initWithArray:members];
    
    NSArray *expels = gCmd.members;
    if (expels.count > 0) {
        // repace item to ID object
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:expels.count];
        for (NSString *item in expels) {
            [mArray addObject:DIMIDWithString(item)];
        }
        expels = mArray;
    }
    
    // 2. check removed member(s)
    NSMutableArray *removeds = [[NSMutableArray alloc] initWithCapacity:expels.count];
    for (DIMID *item in expels) {
        if ([newMembers containsObject:item]) {
            [newMembers removeObject:item];
            [removeds addObject:item];
        } else {
            // NOTE:
            //    the owner will receive the expel command sent by itself
            //    after it's already removed these members from the group,
            //    just ignore this assert.
            //NSAssert(false, @"removing member error: %@, %@", members, expels);
            //return NO;
        }
    }
    if (removeds.count > 0) {
        NSLog(@"expel members: %@ from group: %@", removeds, group.ID);
        
        // 3. save new members list
        if (![[DIMFacebook sharedInstance] saveMembers:newMembers group:group.ID]) {
            NSLog(@"failed to save members of group: %@", group.ID);
            return NO;
        }
    }
    
    // 4. stored 'removed' list
    if (removeds.count > 0) {
        [gCmd setObject:removeds forKey:@"removed"];
    }
    
    return YES;
}

- (BOOL)processQuitCommand:(DIMGroupCommand *)gCmd
                 commander:(DIMID *)sender
                 polylogue:(DIMPolylogue *)group {
    
    // 1. check permission
    if ([group isOwner:sender] || [group existsAssistant:sender]) {
        NSAssert(false, @"%@ is the owner/assistant of polylogue: %@, cannot quit.", sender, group);
        return NO;
    }
    if (![group existsMember:sender]) {
        NSAssert(false, @"%@ is not a member of polylogue: %@, cannot quit.", sender, group);
        return NO;
    }
    
    // 2. remove member
    if (![[DIMFacebook sharedInstance] group:group.ID removeMember:sender]) {
        NSLog(@"failed to remove member of group: %@", group.ID);
        return NO;
    }
    
    return YES;
}

- (BOOL)processGroupCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender {
    BOOL OK = NO;
    
    NSString *command = gCmd.command;
    NSLog(@"command: %@", command);
    
    DIMID *groupID = DIMIDWithString(gCmd.group);
    if (groupID.type == MKMNetwork_Polylogue) {
        DIMPolylogue *group = (DIMPolylogue *)DIMGroupWithID(groupID);
        
        if ([command isEqualToString:DIMGroupCommand_Invite]) {
            OK = [self processInviteCommand:gCmd commander:sender polylogue:group];
        } else if ([command isEqualToString:DIMGroupCommand_Expel]) {
            OK = [self processExpelCommand:gCmd commander:sender polylogue:group];
        } else if ([command isEqualToString:DIMGroupCommand_Quit]) {
            OK = [self processQuitCommand:gCmd commander:sender polylogue:group];
        } else if ([command isEqualToString:DIMGroupCommand_Reset]) {
            OK = [self processResetCommand:gCmd commander:sender polylogue:group];
        } else if ([command isEqualToString:DIMGroupCommand_Query]) {
            OK = [self processQueryCommand:gCmd commander:sender polylogue:group];
        } else {
            NSAssert(false, @"unknown polylogue command: %@", gCmd);
        }
    } else {
        NSAssert(false, @"unsupport group command: %@", gCmd);
    }
    
    return OK;
}

@end
