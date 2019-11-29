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
//  DIMTerminal+Group.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/9.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "MKMGroup+Extension.h"

#import "DIMTerminal+Request.h"

#import "DIMTerminal+Group.h"

@implementation DIMTerminal (GroupManage)

- (BOOL)_sendOutGroupID:(DIMID *)groupID
                   meta:(DIMMeta *)meta
                profile:(nullable DIMProfile *)profile
                members:(NSArray<DIMID *> *)newMembers {
    NSAssert([meta matchID:groupID], @"meta not match group ID: %@, %@", groupID, meta);
    NSAssert(!profile || [profile.ID isEqual:groupID], @"profile not match group ID: %@, %@", groupID, profile);
    
    DIMGroup *group = DIMGroupWithID(groupID);
    DIMUser *user = self.currentUser;
    
    if (group.ID.type != MKMNetwork_Polylogue) {
        NSAssert(false, @"unsupported group type: %@", group.ID);
        return NO;
    }
    
    // checking founder
    DIMID *founder = group.founder;
    if (!founder) {
        // FIXME: new group?
        founder = user.ID;
    }
    if (![founder isValid] || !MKMNetwork_IsPerson(founder.type)) {
        NSAssert(false, @"invalid founder: %@", founder);
        return NO;
    }
    NSUInteger index = [newMembers indexOfObject:founder];
    if (index == NSNotFound) {
        NSAssert(false, @"the founder not found in the member list");
        // add the founder to the front of group members list
        NSMutableArray *mArray = [newMembers mutableCopy];
        [mArray insertObject:founder atIndex:0];
        newMembers = mArray;
    } else if (index != 0) {
        //NSAssert(false, @"the founder must be the first member");
        // move the founder to the front
        NSMutableArray *mArray = [newMembers mutableCopy];
        [mArray exchangeObjectAtIndex:index withObjectAtIndex:0];
        newMembers = mArray;
    }
    
    // checking expeled list with old members
    NSArray<DIMID *> *members = group.members;
    NSMutableArray<DIMID *> *expels;
    expels = [[NSMutableArray alloc] initWithCapacity:members.count];
    for (DIMID *ID in members) {
        // if old member not in the new list, expel it
        if (![newMembers containsObject:ID]) {
            [expels addObject:ID];
        }
    }
    if (expels.count > 0) {
        // only the founder can expel members
        if (![founder isEqual:user.ID]) {
            NSLog(@"user (%@) not the founder of group: %@", user, group);
            return NO;
        }
        if ([expels containsObject:founder]) {
            NSLog(@"cannot expel founder (%@) of group: %@", group.founder, group);
            return NO;
        }
    }
    
    // check membership
    if (![founder isEqual:user.ID] && ![members containsObject:user.ID]) {
    //if (![group existsMember:user.ID]) {
        NSLog(@"user (%@) not a member of group: %@", user, group);
        return NO;
    }
    
    DIMCommand *cmd;
    
    // 1. send out meta & profile
    if (profile) {
        cmd = [[DIMProfileCommand alloc] initWithID:groupID meta:meta profile:profile];
    } else {
        cmd = [[DIMMetaCommand alloc] initWithID:groupID meta:meta];
    }
    
    // 1.1. share to station
    [self sendCommand:cmd];
    
    // 1.2. send to each new member
    for (DIMID *ID in newMembers) {
        [self sendContent:cmd to:ID];
    }
    
    // checking assistants
    NSArray<DIMID *> *assistants = group.assistants;
    NSLog(@"group(%@) assistants: %@", groupID, assistants);
    
    // 2. send expel command
    if (expels.count > 0) {
        cmd = [[DIMExpelCommand alloc] initWithGroup:groupID members:expels];
        // 2.1. send expel command to all old members
        if (members.count > 0) {
            for (DIMID *ID in members) {
                [self sendContent:cmd to:ID];
            }
        }
        // 2.2. send expel command to all assistants
        if (assistants.count > 0) {
            for (DIMID *ID in assistants) {
                [self sendContent:cmd to:ID];
            }
        }
    }
    
    // 3. send invite command
    if (newMembers.count > 0) {
        cmd = [[DIMInviteCommand alloc] initWithGroup:groupID members:newMembers];
        // 3.1. send invite command to all new members
        for (DIMID *ID in newMembers) {
            [self sendContent:cmd to:ID];
        }
        // 3.2. send invite command to all assistants
        if (assistants.count > 0) {
            for (DIMID *ID in assistants) {
                [self sendContent:cmd to:ID];
            }
        }
    }
    
    return YES;
}

- (nullable DIMGroup *)createGroupWithSeed:(NSString *)seed
                                   members:(NSArray<DIMID *> *)list
                                   profile:(NSDictionary *)dict {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    DIMUser *user = self.currentUser;
    
    // generate group meta with current user's private key
    id<MKMPrivateKey> SK = (id)[facebook privateKeyForSignature:user.ID];
    DIMMeta *meta = MKMMetaGenerate(MKMMetaDefaultVersion, SK, seed);
    // generate group ID
    DIMID *ID = [meta generateID:MKMNetwork_Polylogue];
    // save meta for group ID
    [facebook saveMeta:meta forID:ID];
    
    // generate group profile
    NSData *data = [dict jsonData];
    NSData *signature = [user sign:data];
    DIMProfile *profile = [[DIMProfile alloc] initWithID:ID
                                                    data:data
                                               signature:signature];
    NSLog(@"new group: %@, meta: %@, profile: %@", ID, meta, profile);
    
    // send out meta+profile command
    BOOL sent = [self _sendOutGroupID:ID meta:meta profile:profile members:list];
    if (!sent) {
        NSLog(@"failed to send out group: %@, %@, %@, %@", ID, meta, profile, list);
        // TODO: remove the new group info
        return nil;
    }
    
    // create group
    return DIMGroupWithID(ID);
}

- (BOOL)updateGroupWithID:(DIMID *)ID
                  members:(NSArray<DIMID *> *)list
                  profile:(nullable DIMProfile *)profile {
    DIMGroup *group = DIMGroupWithID(ID);
    DIMMeta *meta = group.meta;
    NSLog(@"update group: %@, meta: %@, profile: %@", ID, meta, profile);
    BOOL sent = [self _sendOutGroupID:ID meta:meta profile:profile members:list];
    if (!sent) {
        NSLog(@"failed to send out group: %@, %@, %@, %@", ID, meta, profile, list);
        return NO;
    }
    
    return YES;
}

@end
