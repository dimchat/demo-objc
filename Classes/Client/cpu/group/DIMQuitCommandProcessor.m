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

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDQuitGroupCommand)],
             @"quit command error: %@", content);
    id<DKDGroupCommand> command = content;
    
    // 0. check command
    DIMCommandExpiredResults *pair = [self checkCommandExpired:command
                                                       message:rMsg];
    id<MKMID> group = [pair first];
    if (!group) {
        // ignore expired command
        return [pair second];
    }
    
    // 1. check group
    DIMGroupMembersResults *trip = [self checkGroupMembers:command
                                                   message:rMsg];
    id<MKMID> owner = [trip first];
    DIMIDList *members = [trip second];
    if (!owner || [members count] == 0) {
        return [trip third];
    }
    
    id<MKMID> sender = [rMsg sender];
    DIMIDList *admins = [self administratorsOfGroup:group];
    BOOL isOwner = [owner isEqual:sender];
    BOOL isAdmin = [admins containsObject:sender];
    BOOL isMember = [members containsObject:sender];
    
    // 2. check permission
    if (isOwner) {
        NSDictionary *info = @{
            @"template": @"Owner cannot quit from group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    if (isAdmin) {
        NSDictionary *info = @{
            @"template": @"Administrator cannot quit from group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    
    // 3. do quit
    if (!isMember) {
        // the sender is not a member now,
        // shall we notify the sender that the member list was updated?
    } else if (![self saveHistory:command withMessage:rMsg group:group]) {
        // here try to append the 'quit' command to local storage as group history
        // it should not failed unless the command is expired
        NSLog(@"failed to save 'quit' command for group: %@", group);
    } else {
        NSMutableArray<id<MKMID>> *mArray = [members mutableCopy];
        [mArray removeObject:sender];
        if ([self saveMembers:mArray group:group]) {
            // here try to remove the sender from member list
            [command setObject:sender.string forKey:@"removed"];
        } else {
            // DB error:
            NSAssert(false, @"failed to save members for group: %@", group);
        }
    }
    
    // no need to response this group command
    return nil;
}

@end
