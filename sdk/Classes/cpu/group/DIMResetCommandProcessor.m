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
//  DIMResetCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMFacebook.h"
#import "DIMMessenger.h"

#import "DIMResetCommandProcessor.h"

@implementation DIMResetGroupCommandProcessor

- (nullable DIMContent *)_tempSave:(NSArray<DIMID *> *)newMembers sender:(DIMID *)sender group:(DIMID *)group {
    if ([self containsOwnerInMembers:newMembers group:group]) {
        // it's a full list, save it now
        if ([_facebook saveMembers:newMembers group:group]) {
            DIMID *owner = [_facebook ownerOfGroup:group];
            if (owner && ![owner isEqual:sender]) {
                // NOTICE: to prevent counterfeit,
                //         query the owner for newest member-list
                DIMQueryGroupCommand *query;
                query = [[DIMQueryGroupCommand alloc] initWithGroup:group];
                [_messenger sendContent:query receiver:owner];
            }
        }
        // response (no need to response this group command)
        return nil;
    } else {
        // NOTICE: this is a partial member-list
        //         query the sender for full-list
        return [[DIMQueryGroupCommand alloc] initWithGroup:group];
    }
}

- (NSDictionary *)_doReset:(NSArray<DIMID *> *)newMembers group:(DIMID *)group {
    // existed members
    NSMutableArray<DIMID *> *members = [self convertMembers:[_facebook membersOfGroup:group]];
    // removed list
    NSMutableArray<DIMID *> *removedList = [[NSMutableArray alloc] init];
    for (DIMID *item in members) {
        if ([newMembers containsObject:item]) {
            continue;
        }
        // removing member found
        [removedList addObject:item];
    }
    // added list
    NSMutableArray<DIMID *> *addedList = [[NSMutableArray alloc] init];
    for (DIMID *item in newMembers) {
        if ([members containsObject:item]) {
            continue;
        }
        // adding member found
        [addedList addObject:item];
    }
    NSMutableDictionary *res = [[NSMutableDictionary alloc] initWithCapacity:2];
    if ([addedList count] > 0 || [removedList count] > 0) {
        if (![_facebook saveMembers:newMembers group:group]) {
            // failed to update members
            return res;
        }
        if ([addedList count] > 0) {
            [res setObject:addedList forKey:@"added"];
        }
        if ([removedList count] > 0) {
            [res setObject:removedList forKey:@"removed"];
        }
    }
    return res;
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([content isKindOfClass:[DIMResetGroupCommand class]] ||
             [content isKindOfClass:[DIMInviteCommand class]], @"invite command error: %@", content);
    DIMGroupCommand *cmd = (DIMGroupCommand *)content;
    DIMID *group = [_facebook IDWithString:content.group];
    // new members
    NSArray<DIMID *> *newMembers = [self membersFromCommand:cmd];
    if ([newMembers count] == 0) {
        NSAssert(false, @"invite/reset command error: %@", cmd);
        return nil;
    }
    // 0. check whether group info empty
    if ([self isEmpty:group]) {
        // FIXME: group info lost?
        // FIXME: how to avoid strangers impersonating group member?
        return [self _tempSave:newMembers sender:sender group:group];
    }
    // 1. check permission
    if (![_facebook group:group isOwner:sender]) {
        if (![_facebook group:group hasAssistant:sender]) {
            NSAssert(false, @"%@ is not the owner/assistant of group %@, cannot reset.", sender, group);
            return nil;
        }
    }
    NSDictionary *result = [self _doReset:newMembers group:group];
    NSArray *added = [result objectForKey:@"added"];
    if (added) {
        [content setObject:added forKey:@"added"];
    }
    NSArray *removed = [result objectForKey:@"removed"];
    if (removed) {
        [content setObject:removed forKey:@"removed"];
    }
    // 3. response (no need to response this group command)
    return nil;
}

@end
