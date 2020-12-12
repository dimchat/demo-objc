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
//  DIMMessenger+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMSearchCommand.h"

#import "SCMessenger.h"

#import "DIMMessenger+Extension.h"

NSString * const kNotificationName_MessageSent       = @"MessageSent";
NSString * const kNotificationName_SendMessageFailed = @"SendMessageFailed";

@implementation DIMMessenger (Extension)

+ (instancetype)sharedInstance {
    return [SCMessenger sharedInstance];
}

- (DIMStation *)currentServer {
    NSAssert(false, @"implement me!");
    return nil;
}

- (void)setCurrentServer:(DIMStation *)server {
    NSAssert(false, @"implement me!");
}

- (BOOL)broadcastContent:(id<DKDContent>)content {
    NSAssert(self.currentServer, @"station not connected yet");
    // broadcast IDs
    id<MKMID>everyone = MKMIDFromString(@"everyone@everywhere");
    [content setGroup:everyone];
    return [self sendContent:content receiver:everyone callback:NULL];
}

- (BOOL)sendCommand:(DIMCommand *)cmd {
    DIMStation *server = [self currentServer];
    NSAssert(server, @"server not connected yet");
    return [self sendContent:cmd receiver:server.ID callback:NULL];
}

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryProfileForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMember:(id<MKMID>)member {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMembers:(NSArray<id<MKMID>> *)members {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)postProfile:(id<MKMDocument>)profile {
    MKMUser *user = [self.facebook currentUser];
    id<MKMID>ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    
    id<MKMMeta>meta = user.meta;
    if (![profile verify:meta.key]){
        return NO;
    }
    
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID
                                                     profile:profile];
    return [self sendCommand:cmd];
}

- (BOOL)broadcastProfile:(id<MKMDocument>)profile {
    MKMUser *user = [self.facebook currentUser];
    id<MKMID>ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID
                                                     profile:profile];
    NSArray<id<MKMID>> *contacts = user.contacts;
    BOOL OK = YES;
    for (id<MKMID>contact in contacts) {
        if (!MKMIDIsUser(contact)) {
            NSLog(@"%@ is not a user, do not broadcaset profile to it", contact);
            continue;
        }
        if (![self sendContent:cmd receiver:contact callback:NULL]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)postContacts:(NSArray<id<MKMID>> *)contacts {
    MKMUser *user = [self.facebook currentUser];
    NSAssert([contacts count] > 0, @"contacts cannot be empty");
    // generate password
    id<MKMSymmetricKey>password = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
    // encrypt contacts
    NSData *data = MKMJSONEncode(contacts);
    data = [password encrypt:data];
    // encrypt key
    NSData *key = MKMJSONEncode(password);
    key = [user encrypt:key];
    // pack 'contacts' command
    DIMStorageCommand *cmd;
    cmd = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    cmd.ID = user.ID;
    cmd.data = data;
    cmd.key = key;
    // send to station
    return [self sendCommand:cmd];
}

- (BOOL)queryContacts{
    MKMUser *user = [self.facebook currentUser];
    // pack 'contacts' command
    DIMStorageCommand *cmd;
    cmd = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    cmd.ID = user.ID;
    // send to station
    return [self sendCommand:cmd];
}

- (BOOL)queryMuteList{
    DIMCommand *cmd = [[DIMMuteCommand alloc] initWithList:nil];
    return [self sendCommand:cmd];
}

- (BOOL)queryOnlineUsers {
    DIMCommand *cmd = [[DIMSearchCommand alloc] initWithKeywords:DIMCommand_OnlineUsers];
    return [self sendCommand:cmd];
}

- (BOOL)searchUsersWithKeywords:(NSString *)keywords {
    DIMCommand *cmd = [[DIMSearchCommand alloc] initWithKeywords:keywords];
    return [self sendCommand:cmd];
}

- (BOOL)_isEmptyGroup:(id<MKMID>)group {
    NSArray *members = [self.facebook membersOfGroup:group];
    if ([members count] == 0) {
        return YES;
    }
    id<MKMID>owner = [self.facebook ownerOfGroup:group];
    return !owner;
}

// check whether need to update group
- (BOOL)checkingGroup:(id<DKDContent>)content sender:(id<MKMID>)sender {
    // Check if it is a group message, and whether the group members info needs update
    id<MKMID>group = content.group;
    if (!group || MKMIDIsBroadcast(group)) {
        // 1. personal message
        // 2. broadcast message
        return NO;
    }
    // chek meta for new group ID
    id<MKMMeta>meta = [self.facebook metaForID:group];
    if (!meta) {
        // NOTICE: if meta for group not found,
        //         facebook should query it from DIM network automatically
        // TODO: insert the message to a temporary queue to wait meta
        //NSAssert(false, @"group meta not found: %@", group);
        return YES;
    }
    // query group command
    if ([self _isEmptyGroup:group]) {
        // NOTICE: if the group info not found, and this is not an 'invite' command
        //         query group info from the sender
        if ([content isKindOfClass:[DIMInviteCommand class]] ||
            [content isKindOfClass:[DIMResetGroupCommand class]]) {
            // FIXME: can we trust this stranger?
            //        may be we should keep this members list temporary,
            //        and send 'query' to the owner immediately.
            // TODO: check whether the members list is a full list,
            //       it should contain the group owner(owner)
            return NO;
        } else {
            return [self queryGroupForID:group fromMember:sender];
        }
    } else if ([self.facebook group:group containsMember:sender] ||
               [self.facebook group:group containsAssistant:sender] ||
               [self.facebook group:group isOwner:sender]) {
        // normal membership
        return NO;
    } else {
        // if assistants exist, query them
        NSArray<id<MKMID>> *assistants = [self.facebook assistantsOfGroup:group];
        NSMutableArray<id<MKMID>> *mArray = [[NSMutableArray alloc] initWithCapacity:(assistants.count+1)];
        for (id<MKMID>item in assistants) {
            [mArray addObject:item];
        }
        // if owner found, query it
        id<MKMID>owner = [self.facebook ownerOfGroup:group];
        if (owner && ![mArray containsObject:owner]) {
            [mArray addObject:owner];
        }
        return [self queryGroupForID:group fromMembers:mArray];
    }
}

@end
