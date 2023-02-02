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

#import "DIMFacebook+Extension.h"
#import "DIMMessenger+Extension.h"

#import "DIMGroupManager.h"

@interface DIMGroupManager ()

@property (strong, nonatomic) id<MKMID> group;

@end

@implementation DIMGroupManager

- (instancetype)initWithGroupID:(id<MKMID>)ID {
    if (self = [super init]) {
        self.group = ID;
    }
    return self;
}

- (BOOL)send:(id<DKDContent>)content {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    // check group ID
    id<MKMID> group = [content group];
    if (group) {
        NSAssert([self.group isEqual:group], @"group ID not match: %@, %@", self.group, content);
    } else {
        content.group = self.group;
    }
    // check members
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    if ([members count] == 0) {
        // get group assistant
        NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:self.group];
        NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
        // querying assistants for group info
        [messenger queryGroupForID:self.group fromMembers:assistants];
        return NO;
    }
    // let group assistant to splie and deliver this message to all members
    return [messenger sendContent:content receiver:self.group];
}

#pragma mark Group commands

- (BOOL)_sendGroupCommand:(id<DKDCommand>)command {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    return [messenger sendCommand:command];
}

- (BOOL)_sendGroupCommand:(id<DKDCommand>)command to:(NSArray<id<MKMID>> *)members {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    BOOL OK = YES;
    for (id<MKMID> receiver in members) {
        if (![messenger sendContent:command receiver:receiver]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)invite:(NSArray<id<MKMID>> *)newMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    
    //id<MKMID> owner = [facebook ownerOfGroup:self.group];
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);

    // 0. build 'meta/visa' command
    id<MKMMeta> meta = [facebook metaForID:self.group];
    if (!meta) {
        NSDictionary *info = @{
            @"group" : self.group,
        };
        @throw [NSException exceptionWithName:@"GroupError" reason:@"not ready" userInfo:info];
    }
    id<MKMDocument> doc = [facebook documentForID:self.group type:MKMDocument_Bulletin];
    id<DKDCommand> command;
    if ([[doc propertyKeys] count] == 0) {
        command = [[DIMMetaCommand alloc] initWithID:self.group meta:meta];
    } else {
        command = [[DIMDocumentCommand alloc] initWithID:self.group meta:meta document:doc];
    }
    
    if (members.count <= 2) {  // new group?
        // 1. send 'meta/document' to station and bots
        [self _sendGroupCommand:command];                // to current station
        [self _sendGroupCommand:command to:assistants];  // to group assistants
        // 2. update local storage
        [self addMembers:newMembers];
        members = [facebook membersOfGroup:self.group];
        [self _sendGroupCommand:command to:members];     // to all members
        // 3. send 'invite' command with all members to all members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:self.group members:members];
        [self _sendGroupCommand:command to:assistants];  // to group assistants
        [self _sendGroupCommand:command to:members];     // to all members
    } else {
        // 1. send 'meta/document' to station, bots and all members
        [self _sendGroupCommand:command];                // to current station
        [self _sendGroupCommand:command to:assistants];  // to group assistants
        //[self _sendGroupCommand:command to:members];     // to old members
        [self _sendGroupCommand:command to:newMembers];  // to new members
        // 2. send 'invite' command with new members to old members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:self.group members:newMembers];
        [self _sendGroupCommand:command to:assistants];  // to group assistants
        [self _sendGroupCommand:command to:members];     // to old members
        // 3. update local storage
        [self addMembers:newMembers];
        members = [facebook membersOfGroup:self.group];
        // 4. send 'invite' command with all members to new members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:self.group members:members];
        [self _sendGroupCommand:command to:newMembers];  // to new members
    }
    
    return YES;
}

- (BOOL)expel:(NSArray<id<MKMID>> *)outMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    
    id<MKMID> owner = [facebook ownerOfGroup:self.group];
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    NSAssert(owner, @"failed to get owner group: %@", self.group);
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
    NSAssert([members count] > 0, @"failed to get members of group: %@", self.group);
    
    // 0. check members list
    for (id<MKMID> ass in assistants) {
        if ([outMembers containsObject:ass]) {
            NSAssert(false, @"Cannot expel group assistant: %@", ass);
            return false;
        }
    }
    if ([outMembers containsObject:owner]) {
        NSAssert(false, @"Cannot expel group owner: %@", owner);
        return false;
    }
    
    // 1. send 'expel' command to all members
    id<DKDCommand> command = [[DIMExpelGroupCommand alloc] initWithGroup:self.group members:outMembers];
    // 1.1. send to existed members
    [self _sendGroupCommand:command to:members];
    // 1.2. send to assistants
    [self _sendGroupCommand:command to:assistants];
    
    // 2. update local storage
    return [self removeMembers:outMembers];
}

- (BOOL)quit:(id<MKMID>)me {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    
    id<MKMID> owner = [facebook ownerOfGroup:self.group];
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    NSAssert(owner, @"failed to get owner group: %@", self.group);
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
    NSAssert([members count] > 0, @"failed to get members of group: %@", self.group);
    
    // 0. check members list
    for (id<MKMID> ass in assistants) {
        if ([ass isEqual:me]) {
            NSAssert(false, @"Group assistant cannot quit: %@", ass);
            return false;
        }
    }
    if ([owner isEqual:me]) {
        NSAssert(false, @"Group owner cannot quit: %@", owner);
        return false;
    }
    
    // 1. send 'quit' command to all members
    id<DKDCommand> command = [[DIMQuitGroupCommand alloc] initWithGroup:self.group];
    // 1.1. send to existed members
    [self _sendGroupCommand:command to:members];
    // 1.2. send to assistants
    [self _sendGroupCommand:command to:assistants];
    // 1.3. send to owner
    if (![members containsObject:owner]) {
        [self _sendGroupCommand:command to:@[owner]];
    }
    
    // 2. update local storage
    return [self removeMember:me];
}

#pragma mark Local storage

- (BOOL)addMembers:(NSArray<id<MKMID>> *)newMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    NSMutableArray *mArray;
    if (members) {
        mArray = [members mutableCopy];
    } else {
        mArray = [[NSMutableArray alloc] initWithCapacity:newMembers.count];
    }
    BOOL count = 0;
    for (id<MKMID> ID in newMembers) {
        if ([mArray containsObject:ID]) {
            NSLog(@"member %@ already exists, group: %@", ID, self.group);
            continue;
        }
        [mArray addObject:ID];
        ++count;
    }
    if (count == 0) {
        return NO;
    }
    return [facebook saveMembers:mArray group:self.group];
}

- (BOOL)removeMembers:(NSArray<id<MKMID>> *)outMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:self.group];
    NSMutableArray *mArray;
    if (members) {
        mArray = [members mutableCopy];
    } else {
        mArray = [[NSMutableArray alloc] initWithCapacity:outMembers.count];
    }
    BOOL count = 0;
    for (id<MKMID> ID in outMembers) {
        if (![mArray containsObject:ID]) {
            NSLog(@"member %@ not exists, group: %@", ID, self.group);
            continue;
        }
        [mArray addObject:ID];
        ++count;
    }
    if (count == 0) {
        return NO;
    }
    return [facebook saveMembers:mArray group:self.group];
}

- (BOOL)addMember:(id<MKMID>)member {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    return [facebook group:self.group addMember:member];
}
- (BOOL)removeMember:(id<MKMID>)member {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    return [facebook group:self.group removeMember:member];
}

@end
