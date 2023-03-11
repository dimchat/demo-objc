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
//  DIMQuitCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMQuitCommandProcessor.h"

@implementation DIMQuitGroupCommandProcessor

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDQuitGroupCommand)],
             @"quit command error: %@", content);
    id<DKDQuitGroupCommand> command = (id<DKDQuitGroupCommand>)content;
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
    if ([owner isEqual:sender]) {
        return [self respondText:@"Sorry, owner cannot quit." withGroup:group];
    }
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:group];
    if ([assistants containsObject:sender]) {
        return [self respondText:@"Sorry, assistant cannot quit." withGroup:group];
    }
    
    // 2. remove the sender from group members
    if ([members containsObject:sender]) {
        NSMutableArray<id<MKMID>> *mArray = [members mutableCopy];
        [mArray removeObject:sender];
        [self.facebook saveMembers:mArray group:group];
    }
    
    // 3. respond nothing (DON'T respond group command directly)
    return nil;
}

@end
