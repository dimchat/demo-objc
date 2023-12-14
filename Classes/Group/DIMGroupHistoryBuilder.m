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
//  DIMGroupHistoryBuilder.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMCommonFacebook.h"
#import "DIMCommonMessenger.h"

#import "DIMGroupDelegate.h"
#import "DIMGroupCommandHelper.h"

#import "DIMGroupHistoryBuilder.h"

@interface DIMGroupHistoryBuilder ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;
@property (strong, nonatomic) DIMGroupCommandHelper *helper;

@end

@implementation DIMGroupHistoryBuilder

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        self.helper = [self createHelper];
    }
    return self;
}

- (DIMGroupCommandHelper *)createHelper {
    return [[DIMGroupCommandHelper alloc] initWithDelegate:self.delegate];
}

- (DIMCommonFacebook *)facebook {
    return [self.delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    return [self.delegate messenger];
}

- (NSArray<id<DKDReliableMessage>> *)buildHistoryForGroup:(id<MKMID>)gid {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    id<MKMDocument> doc;
    id<DKDResetGroupCommand> reset;
    id<DKDReliableMessage> rMsg;
    //
    //  0. build 'document' command
    //
    OKPair<id<MKMDocument>, id<DKDReliableMessage>> *docPair = [self buildDocumentCommandForGroup:gid];
    doc = docPair.first;
    rMsg = docPair.second;
    if (doc && rMsg) {
        [messages addObject:rMsg];
    } else {
        NSLog(@"failed to build 'document' command for group: %@", gid);
        return messages;
    }
    //
    //  1. append 'reset' command
    //
    DIMResetCmdMsg *resPair = [self.helper resetCommandMessageForGroup:gid];
    reset = resPair.first;
    rMsg = resPair.second;
    if (reset && rMsg) {
        [messages addObject:rMsg];
    } else {
        NSLog(@"failed to get 'reset' command for group: %@", gid);
        return messages;
    }
    //
    //  2. append other group commands
    //
    NSArray<DIMHistoryCmdMsg *> *histories = [self.helper historiesOfGroup:gid];
    for (DIMHistoryCmdMsg *item in histories) {
        if ([item.first conformsToProtocol:@protocol(DKDResetGroupCommand)]) {
            // 'reset' command already add to the front
            // assert(messages.length == 2, 'group history error: $group, ${history.length}');
            NSLog(@"skip 'reset' command for group: %@", gid);
            continue;
        } else if ([item.first conformsToProtocol:@protocol(DKDResignGroupCommand)]) {
            // 'resign' command, comparing it with document time
            if ([DIMDocumentHelper time:item.first.time isBefore:doc.time]) {
                NSLog(@"expired '%@' command in group: %@, sender: %@", item.first.cmd, gid, item.second.sender);
                continue;
            }
        } else {
            // other commands('invite', 'join', 'quit'), comparing with 'reset' time
            if ([DIMDocumentHelper time:item.first.time isBefore:reset.time]) {
                NSLog(@"expired '%@' command in group: %@, sender: %@", item.first.cmd, gid, item.second.sender);
                continue;
            }
        }
        [messages addObject:item.second];
    }
    // OK
    return messages;
}

- (OKPair<id<MKMDocument>, id<DKDReliableMessage>> *)buildDocumentCommandForGroup:(id<MKMID>)gid {
    id<MKMUser> user = [self.facebook currentUser];
    id<MKMBulletin> doc = [self.delegate bulletinForID:gid];
    if (!user || !doc) {
        NSAssert(user, @"failed to get current user");
        NSLog(@"document not found for group: %@", gid);
        return nil;
    }
    id<MKMID> me = [user ID];
    id<MKMMeta> meta = [self.delegate metaForID:gid];
    id<DKDCommand> command = DIMDocumentCommandResponse(gid, meta, doc);
    id<DKDReliableMessage> rMsg = [self packBroadcastMessage:command sender:me];
    return [[OKPair alloc] initWithFirst:doc second:rMsg];
}

- (DIMResetCmdMsg *)buildResetCommandForGroup:(id<MKMID>)gid
                                      members:(NSArray<id<MKMID>> *)members {
    id<MKMUser> user = [self.facebook currentUser];
    id<MKMID> owner = [self.delegate ownerOfGroup:gid];
    if (!user || !owner) {
        NSAssert(user, @"failed to get current user");
        NSLog(@"owner not found for group: %@", gid);
        return nil;
    }
    id<MKMID> me = [user ID];
    if (![owner isEqual:me]) {
        NSArray<id<MKMID>> *admins = [self.delegate administratorsOfGroup:gid];
        if (![admins containsObject:me]) {
            NSLog(@"not permit to build 'reset' command for group: %@, %@", gid, me);
            return nil;
        }
    }
    if ([members count] == 0) {
        members = [self.delegate membersOfGroup:gid];
        NSAssert([members count] > 0, @"group members not found: %@", gid);
    }
    id<DKDResetGroupCommand> command = DIMGroupCommandReset(gid, members);
    id<DKDReliableMessage> rMsg = [self packBroadcastMessage:command sender:me];
    return [[OKPair alloc] initWithFirst:command second:rMsg];
}

- (id<DKDReliableMessage>)packBroadcastMessage:(id<DKDContent>)content
                                        sender:(id<MKMID>)from {
    id<DKDEnvelope> envelope = DKDEnvelopeCreate(from, MKMAnyone(), nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(envelope, content);
    id<DKDSecureMessage> sMsg = [self.messenger encryptMessage:iMsg];
    if (!sMsg) {
        NSAssert(false, @"failed to encrypt message: %@", envelope);
        return nil;
    }
    id<DKDReliableMessage> rMsg = [self.messenger signMessage:sMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to sign message: %@", envelope);
        return nil;
    }
    return rMsg;
}

@end
