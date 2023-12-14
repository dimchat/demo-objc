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

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDQueryGroupCommand)],
             @"query group command error: %@", content);
    id<DKDQueryGroupCommand> command = content;
    
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
    DIMIDList *bots = [self assistantsOfGroup:group];
    BOOL isMember = [members containsObject:sender];
    BOOL isBot = [bots containsObject:sender];
    
    // 2. check permission
    BOOL canQuery = isMember || isBot;
    if (!canQuery) {
        NSDictionary *info = @{
            @"template": @"Not allowed to query members of group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    
    // check last group time
    NSDate *queryTime = [command lastTime];
    if (queryTime) {
        // check last group history time
        DIMFacebook *facebook = [self facebook];
        NSDate *lastTime = [facebook.archivist lastTimeOfHistoryForID:group];
        NSTimeInterval lt = [lastTime timeIntervalSince1970];
        if (lt < 1) {
            NSAssert(false, @"group history error: %@", group);
        } else if (lt <= [queryTime timeIntervalSince1970]) {
            // group history not updated
            NSDictionary *info = @{
                @"template": @"history not updated: ${ID}, last time: ${time}",
                @"replacements": @{
                    @"ID": group.string,
                    @"time": @(lt),
                },
            };
            return [self respondReceipt:@"Group history not updated."
                               envelope:rMsg.envelope
                                content:command
                                  extra:info];
        }
    }
    
    // 3. send newest group history commands
    BOOL ok = [self sendHistoriesTo:sender group:group];
    NSAssert(ok, @"failed to send history for group: %@ => %@", group, sender);
    
    // no need to response this group command
    return nil;
}

@end
