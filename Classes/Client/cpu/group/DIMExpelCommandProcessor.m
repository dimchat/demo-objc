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
//  DIMExpelCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMGroupManager.h"

#import "DIMExpelCommandProcessor.h"

@implementation DIMExpelGroupCommandProcessor

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDExpelGroupCommand)],
             @"expel command error: %@", content);
    id<DKDExpelGroupCommand> command = (id<DKDExpelGroupCommand>)content;
    DIMGroupManager *manager = [DIMGroupManager sharedInstance];
    
    // 0. check group
    id<MKMID> group = command.group;
    id<MKMID> owner = [manager ownerOfGroup:group];
    NSArray<id<MKMID>> *members = [manager membersOfGroup:group];
    if (!owner || members.count == 0) {
        return [self respondText:@"Group empty." withGroup:group];
    }
    
    // 1. check permission
    id<MKMID> sender = rMsg.sender;
    if (![owner isEqual:sender]) {
        // not the owner? check assistants
        NSArray<id<MKMID>> *assistants = [manager assistantsOfGroup:group];
        if (![assistants containsObject:sender]) {
            return [self respondText:@"Sorry, you are not allowed to expel member from this group."
                           withGroup:group];
        }
    }
    
    // 2. expelling members
    NSArray<id<MKMID>> *expelList = [self membersFromCommand:command];
    if ([expelList count] == 0) {
        return [self respondText:@"Expel command error." withGroup:group];
    }
    // 2.1. check owner
    if ([expelList containsObject:owner]) {
        return [self respondText:@"Group owner cannot be expelled." withGroup:group];
    }
    // 2.2. build expelled-list
    NSMutableArray<id<MKMID>> *mArray = [members mutableCopy];
    NSMutableArray *removedList = [[NSMutableArray alloc] initWithCapacity:expelList.count];
    for (id<MKMID> item in expelList) {
        if (![members containsObject:item]) {
            continue;
        }
        // removing member found
        [removedList addObject:item];
        [mArray removeObject:item];
    }
    // 2.3. do expel
    if ([removedList count] > 0) {
        if ([manager saveMembers:mArray group:group]) {
            [command setObject:MKMIDRevert(removedList) forKey:@"removed"];
        }
    }
    
    // 3. respond nothing (DON'T respond group command directly)
    return nil;
}

@end
