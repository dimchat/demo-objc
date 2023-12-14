// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMClientArchivist.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/15.
//

#import "DIMClientFacebook.h"
#import "DIMCommonMessenger.h"

#import "DIMClientArchivist.h"

@interface DIMClientArchivist () {
    
    DIMFrequencyChecker<id<MKMID>> *_documentResponses;
    
    // group => member
    NSMutableDictionary<id<MKMID>, id<MKMID>> *_lastActiveMembers;
}

@end

@implementation DIMClientArchivist

/* designated initializer */
- (instancetype)initWithDuration:(NSTimeInterval)lifeSpam {
    if (self = [super initWithDuration:lifeSpam]) {
        _documentResponses = [[DIMFrequencyChecker alloc] initWithDuration:DIMArchivist_RespondExpires];
        _lastActiveMembers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)isDocumentResponseExpired:(id<MKMID>)ID force:(BOOL)updated {
    return [_documentResponses isExpired:ID time:nil force:updated];
}

- (void)setLastActiveMember:(id<MKMID>)member group:(id<MKMID>)group {
    [_lastActiveMembers setObject:member forKey:group];
}

// Override
- (BOOL)queryMetaForID:(id<MKMID>)ID {
    if (![self isMetaQueryExpired:ID]) {
        // query not expired yet
        NSLog(@"meta query not expired yet: %@", ID);
        return NO;
    }
    NSLog(@"Querying meta for: %@", ID);
    id<DKDCommand> content = DIMMetaCommandQuery(ID);
    DIMTransmitterResults *pair = [self.messenger sendContent:content
                                                       sender:nil
                                                     receiver:MKMAnyStation()
                                                     priority:1];
    return pair.second != nil;
}

// Override
- (BOOL)queryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID {
    if (![self isDocumentsQueryExpired:ID]) {
        // query not expired yet
        NSLog(@"document query not expired yet: %@", ID);
        return NO;
    }
    NSDate *lastTime = [self lastTimeOfDocuments:docs forID:ID];
    NSLog(@"querying documents for: %@, last time: %@", ID, lastTime);
    id<DKDCommand> content = DIMDocumentCommandQuery(ID, lastTime);
    DIMTransmitterResults *pair = [self.messenger sendContent:content
                                                       sender:nil
                                                     receiver:MKMAnyStation()
                                                     priority:1];
    return pair.second != nil;
}

// Override
- (BOOL)queryMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group {
    if (![self isMembersQueryExpired:group]) {
        // query not expired yet
        NSLog(@"members query not expired yet: %@", group);
        return NO;
    }
    id<MKMUser> user = [self.facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user ID];
    NSDate *lastTime = [self lastTimeOfHistoryForID:group];
    NSLog(@"querying members for group: %@, last time: %@", group, lastTime);
    // build query command for group members
    id<DKDQueryGroupCommand> content = DIMGroupCommandQuery(group, lastTime);
    BOOL ok;
    // 1. check group bots
    ok = [self queryMembersFromAssistantsOfGroup:group sender:me command:content];
    if (ok) {
        return YES;
    }
    // 2. check administrators
    ok = [self queryMembersFromAdministratorsOfGroup:group sender:me command:content];
    if (ok) {
        return YES;
    }
    // 3. check group owner
    ok = [self queryMembersFromOwnerOfGroup:group sender:me command:content];
    if (ok) {
        return YES;
    }
    // all failed, try last active member
    DIMTransmitterResults *pair = nil;
    id<MKMID> lastMember = [_lastActiveMembers objectForKey:group];
    if (lastMember) {
        NSLog(@"querying members from: %@, group: %@", lastMember, group);
        pair = [self.messenger sendContent:content
                                    sender:me
                                  receiver:lastMember
                                  priority:1];
    }
    NSLog(@"group not ready: %@", group);
    return pair.second != nil;
}

// protected
- (BOOL)queryMembersFromAssistantsOfGroup:(id<MKMID>)group
                                   sender:(id<MKMID>)sender
                                  command:(id<DKDQueryGroupCommand>)content {
    NSArray<id<MKMID>> *bots = [self.facebook assistantsOfGroup:group];
    if ([bots count] == 0) {
        NSLog(@"assistants not designated for group: %@", group);
        return NO;
    }
    NSUInteger success = 0;
    DIMTransmitterResults *pair;
    // querying members from bots
    NSLog(@"querying members from bots: %@, group: %@", bots, group);
    for (id<MKMID> receiver in bots) {
        if ([sender isEqual:receiver]) {
            NSLog(@"ignore cycled querying: %@, group: %@", sender, group);
            continue;
        }
        pair = [self.messenger sendContent:content
                                    sender:sender
                                  receiver:receiver
                                  priority:1];
        if ([pair second]) {
            success += 1;
        }
    }
    if (success == 0) {
        // failed
        return NO;
    }
    id<MKMID> lastMember = [_lastActiveMembers objectForKey:group];
    if (!lastMember || [bots containsObject:lastMember]) {
        // last active member is a bot??
    } else {
        NSLog(@"querying members from: %@, group: %@", lastMember, group);
        [self.messenger sendContent:content
                             sender:sender
                           receiver:lastMember
                           priority:1];
    }
    return YES;
}

// protected
- (BOOL)queryMembersFromAdministratorsOfGroup:(id<MKMID>)group
                                       sender:(id<MKMID>)sender
                                      command:(id<DKDQueryGroupCommand>)content {
    DIMClientFacebook *facebook = [self facebook];
    NSArray<id<MKMID>> *admins = [facebook administratorsOfGroup:group];
    if ([admins count] == 0) {
        NSLog(@"administrators not found for group: %@", group);
        return NO;
    }
    NSUInteger success = 0;
    DIMTransmitterResults *pair = nil;
    // querying members from admins
    NSLog(@"querying members from admins: %@, group: %@", admins, group);
    for (id<MKMID> receiver in admins) {
        if ([sender isEqual:receiver]) {
            NSLog(@"ignore cycled querying: %@, group: %@", sender, group);
            continue;
        }
        pair = [self.messenger sendContent:content
                                    sender:sender
                                  receiver:receiver
                                  priority:1];
        if ([pair second]) {
            success += 1;
        }
    }
    if (success == 0) {
        // failed
        return NO;
    }
    id<MKMID> lastMember = [_lastActiveMembers objectForKey:group];
    if (!lastMember || [admins containsObject:lastMember]) {
        // last active member is an dadmin, already queried
    } else {
        NSLog(@"querying members from: %@, group: %@", lastMember, group);
        [self.messenger sendContent:content
                             sender:sender
                           receiver:lastMember
                           priority:1];
    }
    return YES;
}

// protected
- (BOOL)queryMembersFromOwnerOfGroup:(id<MKMID>)group
                              sender:(id<MKMID>)sender
                             command:(id<DKDQueryGroupCommand>)content {
    id<MKMID> owner = [self.facebook ownerOfGroup:group];
    if (!owner) {
        NSLog(@"owner not found for group: %@", group);
        return NO;
    } else if ([owner isEqual:sender]) {
        NSLog(@"you are the owner of group: %@", group);
        return NO;
    }
    DIMTransmitterResults *pair = nil;
    // querying members from owner
    NSLog(@"querying members from owner: %@, group: %@", owner, group);
    pair = [self.messenger sendContent:content sender:sender receiver:owner priority:1];
    if (![pair second]) {
        // failed
        return NO;
    }
    id<MKMID> lastMember = [_lastActiveMembers objectForKey:group];
    if (!lastMember || [lastMember isEqual:owner]) {
        // last active member is the owner, already queried
    } else {
        NSLog(@"querying members from: %@, group: %@", lastMember, group);
        [self.messenger sendContent:content
                             sender:sender
                           receiver:lastMember
                           priority:1];
    }
    return YES;
}

@end
