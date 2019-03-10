//
//  DIMTerminal+Group.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/9.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMTerminal+Group.h"

@implementation DIMTerminal (GroupManage)

- (BOOL)sendOutGroupID:(const DIMID *)groupID
                  meta:(const DIMMeta *)meta
               profile:(nullable const DIMProfile *)profile
               members:(const NSArray<const DIMID *> *)list {
    DIMGroup *group = MKMGroupWithID(groupID);
    DIMUser *user = self.currentUser;
    
    if (group.ID.type == MKMNetwork_Polylogue) {
        if (![group isFounder:user.ID]) {
            NSLog(@"user %@ not the founder of group: %@", user, group);
            return NO;
        }
    } else {
        NSAssert(false, @"unsupported group type: %u", group.ID.type);
    }
    DIMID *ID;
    
    // 1. send out meta & profile
    NSString *string = nil;
    NSString *signature = nil;
    if (profile) {
        string = [profile jsonString];
        signature = [[user.privateKey sign:[string data]] base64Encode];
    }
    
    DIMMessageContent *cmd;
    cmd = [[DIMProfileCommand alloc] initWithID:groupID
                                           meta:meta
                                        profile:string
                                      signature:signature];
    
    // 1.1. share to station
    [self sendCommand:(DIMProfileCommand *)cmd];
    
    // 1.2. send to each member
    for (ID in list) {
        [self sendContent:cmd to:ID];
    }
    
    // 2. send out member list
    NSUInteger index = [list indexOfObject:user.ID];
    if (index == NSNotFound) {
        // add myself to the front of group members list
        NSMutableArray *mArray = [list mutableCopy];
        [mArray insertObject:user.ID atIndex:0];
        list = mArray;
    } else if (index != 0) {
        //NSAssert(false, @"the owner must be the first member");
        // move myself to the front
        NSMutableArray *mArray = [list mutableCopy];
        [mArray exchangeObjectAtIndex:index withObjectAtIndex:0];
        list = mArray;
    }
    
    // 2.1. send expel command to all old members
    NSArray<const DIMID *> *members = group.members;
    if (members.count > 0) {
        NSMutableArray<const DIMID *> *expels;
        expels = [[NSMutableArray alloc] initWithCapacity:members.count];
        for (ID in members) {
            if (![list containsObject:ID]) {
                [expels addObject:ID];
            }
        }
        if (expels.count > 0) {
            cmd = [[DIMExpelCommand alloc] initWithGroup:groupID members:expels];
            [cmd setObject:user.ID forKey:@"owner"];
            for (ID in members) {
                [self sendContent:cmd to:ID];
            }
        }
    }
    
    // 2.2. send invite command to all new members
    cmd = [[DIMInviteCommand alloc] initWithGroup:groupID members:list];
    [cmd setObject:user.ID forKey:@"owner"];
    for (ID in list) {
        [self sendContent:cmd to:ID];
    }
    
    // send to myself
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:cmd
                                               sender:user.ID
                                             receiver:groupID
                                                 time:nil];
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    [clerk saveMessage:iMsg];
    
    return YES;
}

- (DIMGroup *)createGroupWithSeed:(const NSString *)seed
                          members:(const NSArray<const MKMID *> *)list
                          profile:(const NSDictionary *)dict {
    DIMUser *user = self.currentUser;
    
    // generate group meta with current user's private key
    DIMMeta *meta = [[DIMMeta alloc] initWithSeed:seed
                                       privateKey:user.privateKey
                                        publicKey:nil
                                          version:MKMMetaDefaultVersion];
    // generate group ID
    const DIMID *ID = [meta buildIDWithNetworkID:MKMNetwork_Polylogue];
    // save meta for group ID
    DIMBarrack *barrack = [DIMBarrack sharedInstance];
    [barrack saveMeta:meta forEntityID:ID];
    
    // end out meta+profile command
    DIMProfile *profile;
    profile = [[DIMProfile alloc] initWithID:ID];
    for (NSString *key in dict) {
        if ([key isEqualToString:@"ID"]) {
            continue;
        }
        [profile setObject:[dict objectForKey:key] forKey:key];
    }
    NSLog(@"new group: %@, meta: %@, profile: %@", ID, meta, profile);
    BOOL sent = [self sendOutGroupID:ID meta:meta profile:profile members:list];
    if (!sent) {
        NSLog(@"failed to send out group: %@, %@, %@, %@", ID, meta, profile, list);
        return nil;
    }
    
    // create group
    return MKMGroupWithID(ID);
}

- (BOOL)updateGroupWithID:(const MKMID *)ID
                  members:(const NSArray<const MKMID *> *)list
                  profile:(const MKMProfile *)profile {
    DIMGroup *group = MKMGroupWithID(ID);
    const DIMMeta *meta = group.meta;
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match: %@", ID);
        return NO;
    }
    NSLog(@"new group: %@, meta: %@, profile: %@", ID, meta, profile);
    BOOL sent = [self sendOutGroupID:ID meta:meta profile:profile members:list];
    if (!sent) {
        NSLog(@"failed to send out group: %@, %@, %@, %@", ID, meta, profile, list);
        return NO;
    }
    
    return YES;
}

@end

@implementation DIMTerminal (GroupHistory)

- (BOOL)checkPolylogueCommand:(DKDMessageContent *)content
                    commander:(const MKMID *)sender {
    const DIMID *groupID = content.group;
    DIMGroup *group = MKMGroupWithID(groupID);
    NSString *command = content.command;
    // quit command
    if ([command isEqualToString:@"quit"]) {
        if ([group existsMember:sender]) {
            NSLog(@"member will be quit from group: %@, %@", groupID, sender);
            return YES;
        } else if ([group.founder isEqual:sender] ||
                   [group.owner isEqual:sender]) {
            // NOTE: if the founder(owner) quit, it means this group should be dismissed
            NSLog(@"!!! founder(owner) quit, group chat dismissed.");
            return YES;
        } else {
            NSLog(@"!!! commander is not a member of group: %@, %@", groupID, sender);
            return NO;
        }
    }
    NSAssert([command isEqualToString:@"invite"] ||
             [command isEqualToString:@"expel"], @"error command: %@", command);
    
    // check owner
    DIMID *owner = [content objectForKey:@"owner"];
    owner = [DIMID IDWithID:owner];
    if (![sender isEqual:owner]) {
        NSLog(@"!!! only the owner can manage the group: %@, %@", sender, content);
        return NO;
    }
    
    // check founder
    if (![group isFounder:owner]) {
        // polylogue's founder also be owner
        NSLog(@"founder error: %@", owner);
        return NO;
    }
    
    // check members
    NSArray *members = [content objectForKey:@"members"];
    if (members.count == 0) {
        NSLog(@"members is empty: %@", content);
        return NO;
    }
    
    NSLog(@"group: %@, invite/expel members: %@", groupID, members);
    return YES;
}

- (BOOL)checkGroupCommand:(DKDMessageContent *)content
                commander:(const MKMID *)sender {
    const DIMID *groupID = content.group;
    
    if (groupID.type == MKMNetwork_Polylogue) {
        return [self checkPolylogueCommand:content commander:sender];
    } else if (groupID.type == MKMNetwork_Chatroom) {
        // TODO: check by group history consensus
    }
    
    NSAssert(false, @"unsupport group type: %u", groupID.type);
    return NO;
}

@end
