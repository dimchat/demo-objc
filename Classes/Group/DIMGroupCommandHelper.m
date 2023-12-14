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
//  DIMGroupCommandHelper.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMCommonArchivist.h"
#import "DIMGroupDelegate.h"

#import "DIMGroupCommandHelper.h"

@interface DIMGroupCommandHelper ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@end

@implementation DIMGroupCommandHelper

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (id<DIMAccountDBI>)database {
    DIMFacebook *facebook = [self.delegate facebook];
    DIMCommonArchivist *archivist = [facebook archivist];
    return [archivist database];
}

- (BOOL)saveGroupHistory:(id<DKDGroupCommand>)content
                 message:(id<DKDReliableMessage>)rMsg
                   group:(id<MKMID>)gid {
    NSAssert([content.group isEqual:gid], @"group ID error: %@, %@", gid, content);
    if ([self isCommandExpired:content]) {
        NSLog(@"drop expired command: %@, %@ => %@", content.cmd, rMsg.sender, gid);
        return NO;
    }
    // check command time
    NSDate *cmdTime = [content time];
    if (!cmdTime) {
        NSAssert(false, @"group command error: %@", content);
    } else {
        // calibrate the clock
        // make sure the command time is not in the far future
        NSTimeInterval current = [[[NSDate alloc] init] timeIntervalSince1970];
        current += 65.0;
        if ([cmdTime timeIntervalSince1970] > current) {
            NSAssert(false, @"group command time error: %@, %@", cmdTime, content);
            return NO;
        }
    }
    // update group history
    id<DIMAccountDBI> db = [self database];
    if ([content conformsToProtocol:@protocol(DKDResetGroupCommand)]) {
        NSLog(@"cleaning group history for 'reset' command: %@ => %@", rMsg.sender, gid);
        [db clearMemberHistoriesOfGroup:gid];
    }
    return [db saveGroupHistory:content withMessage:rMsg group:gid];
}

- (NSArray<DIMHistoryCmdMsg *> *)historiesOfGroup:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db historiesOfGroup:gid];
}

- (DIMResetCmdMsg *)resetCommandMessageForGroup:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db resetCommandMessageForGroup:gid];
}

- (BOOL)clearMemberHistoriesOfGroup:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db clearMemberHistoriesOfGroup:gid];
}

- (BOOL)clearAdminHistoriesOfGroup:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db clearAdminHistoriesOfGroup:gid];
}

- (BOOL)isCommandExpired:(id<DKDGroupCommand>)content {
    id<MKMID> group = [content group];
    if (!group) {
        NSAssert(false, @"group command error: %@", content);
        return YES;
    }
    if ([content conformsToProtocol:@protocol(DKDResetGroupCommand)]) {
        // administrator command, check with document time
        id<MKMBulletin> doc = [self.delegate bulletinForID:group];
        if (!doc) {
            NSAssert(false, @"group document not exists: %@", group);
            return YES;
        }
        return [DIMDocumentHelper time:content.time isBefore:doc.time];
    }
    // membership command, check with reset command
    DIMResetCmdMsg *pair = [self resetCommandMessageForGroup:group];
    id<DKDResetGroupCommand> cmd = pair.first;
    //id<DKDReliableMessage> msg = pair.second;
    if (!cmd/* || !msg*/) {
        return NO;
    }
    return [DIMDocumentHelper time:content.time isBefore:cmd.time];
}

- (NSArray<id<MKMID>> *)membersFromCommand:(id<DKDGroupCommand>)content {
    // get from 'members'
    NSArray<id<MKMID>> *members = [content members];
    if (!members) {
        // get from 'member'
        id<MKMID> single = [content member];
        if (single) {
            return @[single];
        }
    }
    return members;
}

@end
