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

#import "DIMResetCommandProcessor.h"

@implementation DIMResetGroupCommandProcessor

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDResetGroupCommand)],
             @"invite command error: %@", content);
    id<DKDResetGroupCommand> command = content;
    
    // 0. check command
    DIMCommandExpiredResults *pair = [self checkCommandExpired:command
                                                       message:rMsg];
    id<MKMID> group = [pair first];
    if (!group) {
        // ignore expired command
        return [pair second];
    }
    DIMCommandMembersResults *pair1 = [self checkCommandMembers:command
                                                        message:rMsg];
    DIMIDList *newMembers = [pair1 first];
    if ([newMembers count] == 0) {
        // command error
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
    
    // 2. check permission
    BOOL canReset = isOwner || isAdmin;
    if (!canReset) {
        NSDictionary *info = @{
            @"template": @"Not allowed to reset members of group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    // 2.1. check owner
    if (![newMembers.firstObject isEqual:owner]) {
        NSDictionary *info = @{
            @"template": @"Owner must be the first member of group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    // 2.2. check admins
    BOOL expelAdmin = NO;
    for (id<MKMID> item in admins) {
        if (![newMembers containsObject:item]) {
            expelAdmin = YES;
            break;
        }
    }
    if (expelAdmin) {
        NSDictionary *info = @{
            @"template": @"Not allowed to expel administrator of group: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        return [self respondReceipt:@"Permission denied."
                           envelope:rMsg.envelope
                            content:command
                              extra:info];
    }
    
    // 3. do reset
    OKPair<DIMIDList *, DIMIDList *> *memPair = [self calculateReset:newMembers
                                                             members:members];
    DIMIDList *addList = [memPair first];
    DIMIDList *removeList = [memPair second];
    if (![self saveHistory:command withMessage:rMsg group:group]) {
        // here try to save the 'reset' command to local storage as group history
        // it should not failed unless the command is expired
        NSLog(@"failed to save 'reset' command for group: %@", group);
    } else if ([addList count] == 0 && [removeList count] == 0) {
        // nothing changed
    } else if ([self saveMembers:newMembers group:group]) {
        NSLog(@"new members saved in group: %@", group);
        if ([addList count] > 0) {
            [command setObject:MKMIDRevert(addList) forKey:@"added"];
        }
        if ([removeList count] > 0) {
            [command setObject:MKMIDRevert(removeList) forKey:@"removed"];
        }
    } else {
        // DB error:
        NSAssert(false, @"failed to save members in group: %@", group);
    }
    
    // no need to response this group command
    return nil;
}

// protected
- (OKPair<DIMIDList *, DIMIDList *> *)calculateReset:(DIMIDList *)newMembers
                                             members:(DIMIDList *)oldMembers {
    NSMutableArray<id<MKMID>> *addList = [[NSMutableArray alloc] init];
    NSMutableArray<id<MKMID>> *removeList = [[NSMutableArray alloc] init];
    // build invited-list
    for (id<MKMID> item in newMembers) {
        if ([oldMembers containsObject:item]) {
            continue;
        }
        [addList addObject:item];
    }
    // build expelled-list
    for (id<MKMID> item in oldMembers) {
        if ([newMembers containsObject:item]) {
            continue;
        }
        [removeList addObject:item];
    }
    return [[OKPair alloc] initWithFirst:addList second:removeList];
}

@end
