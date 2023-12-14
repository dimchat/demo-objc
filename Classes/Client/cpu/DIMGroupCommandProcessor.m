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
//  DIMGroupCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMCommonMessenger.h"

#import "DIMGroupDelegate.h"

#import "DIMGroupCommandHelper.h"
#import "DIMGroupHistoryBuilder.h"

#import "DIMGroupCommandProcessor.h"

@implementation DIMGroupCommandProcessor

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDGroupCommand)],
             @"group command error: %@", content);
    id<DKDGroupCommand> command = (id<DKDGroupCommand>)content;
    NSDictionary *info = @{
        @"template": @"Group command (name: ${command}) not support yet!",
        @"replacements": @{
            @"command": command.cmd,
        },
    };
    return [self respondReceipt:@"Command not support."
                       envelope:rMsg.envelope
                        content:command
                          extra:info];
}

- (BOOL)sendHistoriesTo:(id<MKMID>)receiver group:(id<MKMID>)gid {
    NSArray<id<DKDReliableMessage>> *messages = [self.builder buildHistoryForGroup:gid];
    if ([messages count] == 0) {
        NSLog(@"failed to build history for group: %@", gid);
        return NO;
    }
    id<DKDContent> content = DIMForwardContentCreate(messages);
    DIMCommonMessenger *messenger = [self messenger];
    DIMTransmitterResults *res;
    res = [messenger sendContent:content sender:nil receiver:receiver priority:1];
    return res.second != nil;
}

- (BOOL)saveHistory:(id<DKDGroupCommand>)content
        withMessage:(id<DKDReliableMessage>)rMsg
              group:(id<MKMID>)gid {
    return [self.helper saveGroupHistory:content message:rMsg group:gid];
}

@end

@implementation DIMGroupCommandProcessor (Membership)

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)gid {
    return [self.delegate ownerOfGroup:gid];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)gid {
    return [self.delegate assistantsOfGroup:gid];
}

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid {
    return [self.delegate administratorsOfGroup:gid];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid {
    return [self.delegate saveAdministrators:admins group:gid];
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)gid {
    return [self.delegate membersOfGroup:gid];
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid {
    return [self.delegate saveMembers:members group:gid];
}

@end

@implementation DIMGroupCommandProcessor (Checking)

- (DIMCommandExpiredResults *)checkCommandExpired:(id<DKDGroupCommand>)content
                                          message:(id<DKDReliableMessage>)rMsg {
    id<MKMID> group = [content group];
    if (!group) {
        NSAssert(false, @"group command error: %@", content);
        return nil;
    }
    NSArray<id<DKDContent>> *errors;
    BOOL expired = [self.helper isCommandExpired:content];
    if (expired) {
        NSDictionary *info = @{
            @"template": @"Group command expired: ${cmd}, group: ${ID}",
            @"replacements": @{
                @"cmd": content.cmd,
                @"ID": group.string,
            },
        };
        errors = [self respondReceipt:@"Command expired."
                             envelope:rMsg.envelope
                              content:content
                                extra:info];
        group = nil;
    } else {
        // group ID must not empty here
        errors = nil;
    }
    return [[OKPair alloc] initWithFirst:group second:errors];
}

- (DIMCommandMembersResults *)checkCommandMembers:(id<DKDGroupCommand>)content
                                          message:(id<DKDReliableMessage>)rMsg {
    id<MKMID> group = [content group];
    if (!group) {
        NSAssert(false, @"group command error: %@", content);
        return nil;
    }
    NSArray<id<DKDContent>> *errors;
    NSArray<id<MKMID>> *members = [self.helper membersFromCommand:content];
    if ([members count] == 0) {
        NSDictionary *info = @{
            @"template": @"Group members empty: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        errors = [self respondReceipt:@"Command error."
                             envelope:rMsg.envelope
                              content:content
                                extra:info];
    } else {
        // normally
        errors = nil;
    }
    return [[OKPair alloc] initWithFirst:group second:errors];
}

- (DIMGroupMembersResults *)checkGroupMembers:(id<DKDGroupCommand>)content
                                      message:(id<DKDReliableMessage>)rMsg {
    id<MKMID> group = [content group];
    if (!group) {
        NSAssert(false, @"group command error: %@", content);
        return nil;
    }
    NSArray<id<DKDContent>> *errors;
    id<MKMID> owner = [self ownerOfGroup:group];
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if (!owner || [members count] == 0) {
        // TODO: query group members?
        NSDictionary *info = @{
            @"template": @"Group empty: ${ID}",
            @"replacements": @{
                @"ID": group.string,
            },
        };
        errors = [self respondReceipt:@"Group empty."
                             envelope:rMsg.envelope
                              content:content
                                extra:info];
    } else {
        // normally
        errors = nil;
    }
    return [[OKTriplet alloc] initWithFirst:owner second:members third:errors];
}

@end
