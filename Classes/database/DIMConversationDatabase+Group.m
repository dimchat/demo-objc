//
//  DIMConversationDatabase+Group.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMGroup+Extension.h"
#import "DIMFacebook.h"
#import "DIMClientConstants.h"
#import "DIMConversationDatabase.h"

static inline NSString *readable_name(DIMID *ID) {
    DIMProfile *profile = DIMProfileForID(ID);
    NSString *nickname = profile.name;
    NSString *username = ID.name;
    if (nickname) {
        if (username && MKMNetwork_IsUser(ID.type)) {
            return [NSString stringWithFormat:@"%@ (%@)", nickname, username];
        }
        return nickname;
    } else if (username) {
        return username;
    } else {
        // BTC Address
        return (NSString *)ID.address;
    }
}

@implementation DIMConversationDatabase (GroupCommand)

- (BOOL)processQueryCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group {
    
    // 1. check permission
    if (![group existsMember:sender] && ![group existsAssistant:sender]) {
        NSAssert(false, @"%@ is not a member/assistant of polylogue: %@, cannot query.", sender, group);
        return NO;
    }
    
    // 2. build message
    NSString *format = NSLocalizedString(@"%@ was querying group info, responding...", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(sender)];
    NSAssert(![gCmd objectForKey:@"text"], @"text should be empty here: %@", gCmd);
    [gCmd setObject:text forKey:@"text"];
    
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
    
    // 4. build message
    NSString *format = NSLocalizedString(@"%@ has updated group members", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(sender)];
    if (removeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:removeds.count];
        for (DIMID *item in removeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@",\n"];
        text = [text stringByAppendingFormat:@", %@ %@", NSLocalizedString(@"removed", nil), str];
        [gCmd setObject:removeds forKey:@"removed"];
    }
    if (addeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:addeds.count];
        for (DIMID *item in addeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@",\n"];
        text = [text stringByAppendingFormat:@", %@ %@", NSLocalizedString(@"invited", nil), str];
        [gCmd setObject:addeds forKey:@"added"];
    }
    NSAssert(![gCmd objectForKey:@"text"], @"text should be empty here: %@", gCmd);
    [gCmd setObject:text forKey:@"text"];
    
    return YES;
}

- (BOOL)processInviteCommand:(DIMGroupCommand *)gCmd
                   commander:(DIMID *)sender
                   polylogue:(DIMPolylogue *)group {
    
    // 0. check permission
    if (group.founder == nil && group.members.count == 0) {
        // FIXME: group profile lost?
        // FIXME: how to avoid strangers impersonating group members?
    } else if (![group existsMember:sender] && ![group existsAssistant:sender]) {
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
    
    // 4. build message
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:invites.count];
    for (DIMID *item in addeds) {
        [mArr addObject:readable_name(DIMIDWithString(item))];
    }
    NSString *str = [mArr componentsJoinedByString:@",\n"];
    NSString *format = NSLocalizedString(@"%@ has invited member(s):\n%@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(sender), str];
    NSAssert(![gCmd objectForKey:@"text"], @"text should be empty here: %@", gCmd);
    [gCmd setObject:text forKey:@"text"];
    [gCmd setObject:addeds forKey:@"added"];
    
    return YES;
}

- (BOOL)processExpelCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group {
    
    // 1. check permission
    if (![group isOwner:sender] && ![group existsAssistant:sender]) {
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
    
    // 4. build message
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:expels.count];
    for (DIMID *item in expels) {
        [mArr addObject:readable_name(DIMIDWithString(item))];
    }
    NSString *str = [mArr componentsJoinedByString:@",\n"];
    NSString *format = NSLocalizedString(@"%@ has removed member(s):\n%@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(sender), str];
    NSAssert(![gCmd objectForKey:@"text"], @"text should be empty here: %@", gCmd);
    [gCmd setObject:text forKey:@"text"];
    [gCmd setObject:removeds forKey:@"removed"];
    
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
    if (![[DIMFacebook sharedInstance] group:group removeMember:sender]) {
        NSLog(@"failed to remove member of group: %@", group.ID);
        return NO;
    }
    
    // 3. build message
    NSString *format = NSLocalizedString(@"%@ has quitted group chat.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(sender)];
    NSAssert(![gCmd objectForKey:@"text"], @"text should be empty here: %@", gCmd);
    [gCmd setObject:text forKey:@"text"];
    
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
    
    if(OK){
        
        DIMID *groupID = DIMIDWithString(gCmd.group);
        NSString *name = kNotificationName_GroupMembersUpdated;
        NSDictionary *info = @{@"group": groupID};
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:info];
    }
    
    return OK;
}

@end
