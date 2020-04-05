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

@property (strong, nonatomic) MKMID *group;

@end

@implementation DIMGroupManager

- (instancetype)initWithGroupID:(DIMID *)ID {
    if (self = [super init]) {
        self.group = ID;
    }
    return self;
}

- (BOOL)send:(DIMContent *)content {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    // check group ID
    NSString *gid = [content group];
    if (gid) {
        NSAssert([self.group isEqual:gid], @"group ID not match: %@, %@", self.group, content);
    } else {
        content.group = self.group;
    }
    // check members
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    if ([members count] == 0) {
        // get group assistant
        NSArray<DIMID *> *assistants = [facebook assistantsOfGroup:self.group];
        NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
        // querying assistants for group info
        [messenger queryGroupForID:self.group fromMembers:assistants];
        return NO;
    }
    // let group assistant to splie and deliver this message to all members
    return [messenger sendContent:content receiver:self.group];
}

#pragma mark Group commands

- (BOOL)_sendGroupCommand:(DIMCommand *)cmd to:(NSArray<DIMID *> *)members {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    BOOL OK = YES;
    for (DIMID *receiver in members) {
        if (![messenger sendContent:cmd receiver:receiver]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)invite:(NSArray<DIMID *> *)newMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    DIMCommand *cmd;
    
    // 0. send 'meta/profile' command to new members
    DIMMeta *meta = [facebook metaForID:self.group];
    NSAssert(meta, @"failed to get meta for group: %@", self.group);
    DIMProfile *profile = [facebook profileForID:self.group];
    if ([[profile propertyKeys] count] == 0) {
        cmd = [[DIMMetaCommand alloc] initWithID:self.group
                                            meta:meta];
    } else {
        cmd = [[DIMProfileCommand alloc] initWithID:self.group
                                               meta:meta
                                            profile:profile];
    }
    [self _sendGroupCommand:cmd to:newMembers];
    
    // 1. send 'invite' command with new members to existed members
    DIMID *owner = [facebook ownerOfGroup:self.group];
    NSArray<DIMID *> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
    cmd = [[DIMInviteCommand alloc] initWithGroup:self.group members:newMembers];
    // 1.1. send to existed members
    [self _sendGroupCommand:cmd to:members];
    // 1.2. send to assistants
    [self _sendGroupCommand:cmd to:assistants];
    // 1.3. send to owner
    if (owner && ![members containsObject:owner]) {
        [self _sendGroupCommand:cmd to:@[owner]];
    }
    
    // 2. update local storage
    [self addMembers:newMembers];
    
    // 3. send 'invite' with all members command to new members
    members = [facebook membersOfGroup:self.group];
    cmd = [[DIMInviteCommand alloc] initWithGroup:self.group members:members];
    [self _sendGroupCommand:cmd to:newMembers];
    
    return YES;
}

- (BOOL)expel:(NSArray<DIMID *> *)outMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    
    DIMID *owner = [facebook ownerOfGroup:self.group];
    NSArray<DIMID *> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    NSAssert(owner, @"failed to get owner group: %@", self.group);
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
    NSAssert([members count] > 0, @"failed to get members of group: %@", self.group);
    
    // 0. check members list
    for (DIMID *ass in assistants) {
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
    DIMCommand *cmd = [[DIMExpelCommand alloc] initWithGroup:self.group members:outMembers];
    // 1.1. send to existed members
    [self _sendGroupCommand:cmd to:members];
    // 1.2. send to assistants
    [self _sendGroupCommand:cmd to:assistants];
    // 1.3. send to owner
    if (![members containsObject:owner]) {
        [self _sendGroupCommand:cmd to:@[owner]];
    }
    
    // 2. update local storage
    return [self removeMembers:outMembers];
}

- (BOOL)quit:(DIMID *)me {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    
    DIMID *owner = [facebook ownerOfGroup:self.group];
    NSArray<DIMID *> *assistants = [facebook assistantsOfGroup:self.group];
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    NSAssert(owner, @"failed to get owner group: %@", self.group);
    NSAssert([assistants count] > 0, @"failed to get assistant for group: %@", self.group);
    NSAssert([members count] > 0, @"failed to get members of group: %@", self.group);
    
    // 0. check members list
    for (DIMID *ass in assistants) {
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
    DIMCommand *cmd = [[DIMQuitCommand alloc] initWithGroup:self.group];
    // 1.1. send to existed members
    [self _sendGroupCommand:cmd to:members];
    // 1.2. send to assistants
    [self _sendGroupCommand:cmd to:assistants];
    // 1.3. send to owner
    if (![members containsObject:owner]) {
        [self _sendGroupCommand:cmd to:@[owner]];
    }
    
    // 2. update local storage
    return [self removeMember:me];
}

#pragma mark Local storage

- (BOOL)addMembers:(NSArray<DIMID *> *)newMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    NSMutableArray *mArray;
    if (members) {
        mArray = [members mutableCopy];
    } else {
        mArray = [[NSMutableArray alloc] initWithCapacity:newMembers.count];
    }
    BOOL count = 0;
    for (DIMID *ID in newMembers) {
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

- (BOOL)removeMembers:(NSArray<DIMID *> *)outMembers {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray<DIMID *> *members = [facebook membersOfGroup:self.group];
    NSMutableArray *mArray;
    if (members) {
        mArray = [members mutableCopy];
    } else {
        mArray = [[NSMutableArray alloc] initWithCapacity:outMembers.count];
    }
    BOOL count = 0;
    for (DIMID *ID in outMembers) {
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

- (BOOL)addMember:(DIMID *)member {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    return [facebook group:self.group addMember:member];
}
- (BOOL)removeMember:(DIMID *)member {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    return [facebook group:self.group removeMember:member];
}

@end
