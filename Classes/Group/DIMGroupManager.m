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

#import "DIMClientFacebook.h"

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

@interface DIMGroupManager () {
    
    NSMutableDictionary<id<MKMID>, id<MKMID>>  *_cachedGroupFounders;
    NSMutableDictionary<id<MKMID>, id<MKMID>>  *_cachedGroupOwners;
    NSMutableDictionary<id<MKMID>, UserList *> *_cachedGroupMembers;
    NSMutableDictionary<id<MKMID>, UserList *> *_cachedGroupAssistants;
    UserList *_defaultAssistants;
}

@end

@implementation DIMGroupManager

OKSingletonImplementations(DIMGroupManager, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _cachedGroupFounders   = [[NSMutableDictionary alloc] init];
        _cachedGroupOwners     = [[NSMutableDictionary alloc] init];
        _cachedGroupMembers    = [[NSMutableDictionary alloc] init];
        _cachedGroupAssistants = [[NSMutableDictionary alloc] init];
        _defaultAssistants     = [[NSMutableArray alloc] init];
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    return [_messenger facebook];
}

- (BOOL)sendContent:(id<DKDContent>)content group:(id<MKMID>)group {
    NSAssert(MKMIDIsGroup(group), @"group ID error: %@", group);
    id<MKMID> gid = [content group];
    if (gid) {
        NSAssert([gid isEqual:group], @"group ID not match: %@, %@", gid, group);
    } else {
        [content setGroup:group];
    }
    NSArray<id<MKMID>> *assistants = [self assistantsOfGroup:group];
    OKPair<id<DKDInstantMessage>, id<DKDReliableMessage>> *results;
    for (id<MKMID> bot in assistants) {
        // send to any bot
        results = [_messenger sendContent:content
                                   sender:nil
                                 receiver:bot
                                 priority:STDeparturePriorityNormal];
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
    [_messenger sendContent:content
                     sender:nil
                   receiver:to
                   priority:STDeparturePriorityNormal];
}

- (void)sendCommand:(id<DKDCommand>)content members:(NSArray<id<MKMID>> *)members {
    NSAssert([members count] > 0, @"receivers should not be empty");
    for (id<MKMID> item in members) {
        [self sendCommand:content receiver:item];
    }
}

- (BOOL)inviteMember:(id<MKMID>)member group:(id<MKMID>)gid {
    return [self inviteMembers:@[member] group:gid];
}

- (BOOL)inviteMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)group {
    NSAssert(MKMIDIsGroup(group), @"group ID error: %@", group);
    
    // TODO: make sure group meta exists
    // TODO: make sure current user is a member

    // 0. build 'meta/document' command
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMMeta> meta = [facebook metaForID:group];
    if (!meta) {
        NSAssert(false, @"failed to get meta for group: %@", group);
        return NO;
    }
    id<MKMDocument> doc = [facebook documentForID:group type:@"*"];
    id<DKDCommand> command;
    if (doc) {
        command = [[DIMDocumentCommand alloc] initWithID:group
                                                    meta:meta
                                                document:doc];
    } else {
        // empty document
        command = [[DIMMetaCommand alloc] initWithID:group
                                                meta:meta];
    }
    NSArray<id<MKMID>> *bots = [facebook assistantsOfGroup:group];
    // 1. send 'meta/document' command
    [self sendCommand:command members:bots];            // to all assistants
    
    // 2. update local members and notice all bots & members
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if ([members count] <= 2) { // new group?
        // 2.0. update local storage
        members = [self addMembers:newMembers group:group];
        // 2.1. send 'meta/document' command
        [self sendCommand:command members:members];     // to all members
        // 2.2. send 'invite' command with all members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:group
                                                       members:members];
        [self sendCommand:command members:bots];        // to group assistants
        [self sendCommand:command members:members];     // to all members
    } else {
        // 2.1. send 'meta/document' command
        //[self sendCommand:command members:members];   // to old members
        [self sendCommand:command members:newMembers];  // to new members
        // 2.2. send 'invite' command with new members only
        command = [[DIMInviteGroupCommand alloc] initWithGroup:group
                                                       members:newMembers];
        [self sendCommand:command members:bots];        // to group assistants
        [self sendCommand:command members:members];     // to old members
        // 2.3. update local storage
        members = [self addMembers:newMembers group:group];
        // 2.4. send 'invite' command with all members
        command = [[DIMInviteGroupCommand alloc] initWithGroup:group
                                                       members:members];
        [self sendCommand:command members:newMembers];  // to new members
    }
    
    return YES;
}

- (BOOL)expelMember:(id<MKMID>)member group:(id<MKMID>)gid {
    return [self expelMembers:@[member] group:gid];
}

- (BOOL)expelMembers:(NSArray<id<MKMID>> *)outMembers group:(id<MKMID>)group {
    NSAssert(MKMIDIsGroup(group), @"group ID error: %@", group);
    id<MKMID> owner = [self ownerOfGroup:group];
    NSArray<id<MKMID>> *bots = [self assistantsOfGroup:group];

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
    NSArray<id<MKMID>> *members = [self removeMembers:outMembers group:group];
    
    id<DKDCommand> command;
    // 2. send 'expel' command
    command = [[DIMExpelGroupCommand alloc] initWithGroup:group
                                                  members:outMembers];
    [self sendCommand:command members:bots];        // to assistants
    [self sendCommand:command members:members];     // to new members
    [self sendCommand:command members:outMembers];  // to expelled members

    return YES;
}

- (BOOL)quitGroup:(id<MKMID>)group  {
    NSAssert(MKMIDIsGroup(group), @"group ID error: %@", group);
    
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMUser> user = [facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = user.ID;

    id<MKMID> owner = [self ownerOfGroup:group];
    NSArray<id<MKMID>> *bots = [self assistantsOfGroup:group];
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    
    // 0. check permission
    if ([bots containsObject:me]) {
        NSAssert(false, @"group assistant cannot quilt: %@, %@", me, group);
        return NO;
    } else if ([me isEqual:owner]) {
        NSAssert(false, @"group owner cannot quilt: %@, %@", me, group);
        return NO;
    }
    
    // 1. update local storage
    if ([members containsObject:me]) {
        NSMutableArray *mArray = mutable_array(members);
        [mArray removeObject:me];
        members = mArray;
        
        [self saveMembers:members group:group];
    //} else {
    //    // not a member now
    //    return NO;
    }
    
    id<DKDCommand> command;
    // 2. send 'quit' command
    command = [[DIMQuitGroupCommand alloc] initWithGroup:group];
    [self sendCommand:command members:bots];     // to assistants
    [self sendCommand:command members:members];  // to new members

    return YES;
}

- (BOOL)queryGroup:(id<MKMID>)group  {
    return [_messenger queryMembersForID:group];
}

#pragma mark Data Source

// Override
- (id<MKMMeta>)metaForID:(id<MKMID>)ID {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook metaForID:ID];
}

// Override
- (id<MKMDocument>)documentForID:(id<MKMID>)ID type:(NSString *)type {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook documentForID:ID type:type];
}

// Override
- (id<MKMID>)founderOfGroup:(id<MKMID>)group {
    id<MKMID> founder = [_cachedGroupFounders objectForKey:group];
    if (!founder) {
        DIMCommonFacebook *facebook = [self facebook];
        founder = [facebook founderOfGroup:group];
        if (!founder) {
            // place holder
            founder = MKMFounder();
        }
        [_cachedGroupFounders setObject:founder forKey:group];
    }
    if (MKMIDIsBroadcast(founder)) {
        return nil;
    }
    return founder;
}

// Override
- (id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    id<MKMID> owner = [_cachedGroupOwners objectForKey:group];
    if (!owner) {
        DIMCommonFacebook *facebook = [self facebook];
        owner = [facebook ownerOfGroup:group];
        if (!owner) {
            // place holder
            owner = MKMAnyone();
        }
        [_cachedGroupOwners setObject:owner forKey:group];
    }
    if (MKMIDIsBroadcast(owner)) {
        return nil;
    }
    return owner;
}

// Override
- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    NSMutableArray<id<MKMID>> *members = [_cachedGroupMembers objectForKey:group];
    if (!members) {
        DIMCommonFacebook *facebook = [self facebook];
        members = mutable_array([facebook membersOfGroup:group]);
        if (!members) {
            // place holder
            members = [[NSMutableArray alloc] init];
        }
        [_cachedGroupMembers setObject:members forKey:group];
    }
    return members;
}

// Override
- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    NSMutableArray<id<MKMID>> *assistants = [_cachedGroupAssistants objectForKey:group];
    if (!assistants) {
        DIMCommonFacebook *facebook = [self facebook];
        assistants = mutable_array([facebook assistantsOfGroup:group]);
        if (!assistants) {
            // place holder
            assistants = [[NSMutableArray alloc] init];
        }
        [_cachedGroupAssistants setObject:assistants forKey:group];
    }
    if ([assistants count] > 0) {
        return assistants;
    }
    // get from global setting
    if ([_defaultAssistants count] == 0) {
        // get from ANS
        id<MKMID> bot = [[DIMClientFacebook ans] getID:@"assistant"];
        if (bot) {
            [_defaultAssistants addObject:bot];
        }
    }
    return _defaultAssistants;
}

@end

@implementation DIMGroupManager (MemberShip)

- (BOOL)isFounder:(id<MKMID>)member group:(id<MKMID>)group {
    id<MKMID> founder = [self founderOfGroup:group];
    if (founder) {
        return [founder isEqual:member];
    }
    // check member's public key with group's meta.key
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMMeta> gMeta = [facebook metaForID:group];
    NSAssert(gMeta, @"failed to get meta for group: %@", group);
    id<MKMMeta> mMeta = [facebook metaForID:member];
    NSAssert(mMeta, @"failed to get meta for member: %@", member);
    return MKMMetaMatchKey(mMeta.key, gMeta);
}

- (BOOL)isOwner:(id<MKMID>)member group:(id<MKMID>)group {
    id<MKMID> owner = [self founderOfGroup:group];
    if (owner) {
        return [owner isEqual:member];
    }
    if (group.type == MKMEntityType_Group) {
        // this is a polylogue
        return [self isFounder:member group:group];
    }
    NSAssert(false, @"only Polylogue so far: %@", group);
    return NO;
}

//
//  members
//

- (BOOL)containsMember:(id<MKMID>)member group:(id<MKMID>)group {
    NSAssert(MKMIDIsUser(member) && MKMIDIsGroup(group), @"ID error: %@, %@", member, group);
    NSArray<id<MKMID>> *allMembers = [self membersOfGroup:group];
    NSUInteger pos = [allMembers indexOfObject:member];
    if (pos != NSNotFound) {
        return YES;
    }
    id<MKMID> owner = [self ownerOfGroup:group];
    return [owner isEqual:member];
}

- (BOOL)addMember:(id<MKMID>)member group:(id<MKMID>)group {
    NSAssert(MKMIDIsUser(member) && MKMIDIsGroup(group), @"ID error: %@, %@", member, group);
    NSArray<id<MKMID>> *allMembers = [self membersOfGroup:group];
    NSUInteger pos = [allMembers indexOfObject:member];
    if (pos != NSNotFound) {
        // already exists
        return NO;
    }
    NSMutableArray *mArray = mutable_array(allMembers);
    [mArray addObject:member];
    return [self saveMembers:mArray group:group];
}

- (BOOL)removeMember:(id<MKMID>)member group:(id<MKMID>)group {
    NSAssert(MKMIDIsUser(member) && MKMIDIsGroup(group), @"ID error: %@, %@", member, group);
    NSArray<id<MKMID>> *allMembers = [self membersOfGroup:group];
    NSUInteger pos = [allMembers indexOfObject:member];
    if (pos == NSNotFound) {
        // not exists
        return NO;
    }
    NSMutableArray *mArray = mutable_array(allMembers);
    [mArray removeObject:member];
    return [self saveMembers:mArray group:group];
}

// private
- (NSArray<id<MKMID>> *)addMembers:(NSArray<id<MKMID>> *)newMembers
                             group:(id<MKMID>)group {
    NSMutableArray *allMembers = mutable_array([self membersOfGroup:group]);
    NSUInteger count = 0;
    for (id<MKMID> member in newMembers) {
        if ([allMembers containsObject:member]) {
            continue;
        }
        [allMembers addObject:member];
        ++count;
    }
    if (count > 0) {
        [self saveMembers:allMembers group:group];
    }
    return allMembers;
}

- (NSArray<id<MKMID>> *)removeMembers:(NSArray<id<MKMID>> *)outMembers
                                group:(id<MKMID>)group {
    NSMutableArray *allMembers = mutable_array([self membersOfGroup:group]);
    NSUInteger count = 0;
    for (id<MKMID> member in outMembers) {
        if (![allMembers containsObject:member]) {
            continue;
        }
        [allMembers removeObject:member];
        ++count;
    }
    if (count > 0) {
        [self saveMembers:allMembers group:group];
    }
    return allMembers;
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    id<DIMAccountDBI> db = [facebook database];
    if ([db saveMembers:members group:group]) {
        // erase cache for reload
        [_cachedGroupMembers removeObjectForKey:group];
        return YES;
    } else {
        return NO;
    }
}

//
//  assistants
//

- (BOOL)containsAssistant:(id<MKMID>)bot group:(id<MKMID>)group {
    NSArray<id<MKMID>> *assitants = [self assistantsOfGroup:group];
    if (assitants == _defaultAssistants) {
        // assistants not found
        return NO;
    }
    return [assitants containsObject:bot];
}

- (BOOL)addAssistant:(id<MKMID>)bot group:(id<MKMID>)group {
    if (!group) {
        [_defaultAssistants insertObject:bot atIndex:0];
        return YES;
    }
    NSMutableArray<id<MKMID>> *mArray;
    NSArray<id<MKMID>> *assistants = [self assistantsOfGroup:group];
    if (assistants == _defaultAssistants) {
        // assistants not found
        mArray = [[NSMutableArray alloc] init];
    } else if ([assistants containsObject:bot]) {
        // already exists
        return NO;
    } else {
        mArray = mutable_array(assistants);
    }
    [mArray insertObject:bot atIndex:0];
    return [self saveAssistants:mArray group:group];
}

- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    id<DIMAccountDBI> db = [facebook database];
    if ([db saveAssistants:bots group:group]) {
        // erase cache for reload
        [_cachedGroupAssistants removeObjectForKey:group];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)removeGroup:(id<MKMID>)group {
    // TODO: remove group completely
    return NO;
}

@end
