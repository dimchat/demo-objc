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
//  DIMQueryCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMQueryCommandProcessor.h"

@implementation DIMQueryGroupCommandProcessor

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDQueryGroupCommand)],
             @"query group command error: %@", content);
    id<DKDQueryGroupCommand> command = (id<DKDQueryGroupCommand>)content;
    DIMFacebook *facebook = self.facebook;
    
    // 0. check group
    id<MKMID> group = command.group;
    id<MKMID> owner = [facebook ownerOfGroup:group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:group];
    if (!owner || members.count == 0) {
        return [self respondText:@"Group empty." withGroup:group];
    }

    // 1. check permission
    id<MKMID> sender = rMsg.sender;
    if (![members containsObject:sender]) {
        // not a member? check assistants
        NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:group];
        if (![assistants containsObject:sender]) {
            return [self respondText:@"Sorry, you are not allowed to query this group." withGroup:group];
        }
    }
    
    // 2. respond
    id<DIMUser> user = [self.facebook currentUser];
    NSAssert(user, @"current user not set");
    id<DKDCommand> res;
    if ([user.ID isEqual:owner]) {
        res = [[DIMResetGroupCommand alloc] initWithGroup:group members:members];
    } else {
        res = [[DIMInviteGroupCommand alloc] initWithGroup:group members:members];
    }
    return [self respondContent:res];
}

@end
