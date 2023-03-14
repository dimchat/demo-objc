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
//  DIMClientMessenger.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMQueryFrequencyChecker.h"
#import "DIMHandshakeCommand.h"
#import "DIMReportCommand.h"
#import "DIMClientSession.h"

#import "DIMClientMessenger.h"

@interface DIMClientMessenger ()

@property(nonatomic, strong) NSDate *offlineTime;

@end

@implementation DIMClientMessenger

- (void)handshake:(NSString *)sessionKey {
    DIMClientSession *session = [self session];
    id<MKMStation> station = [session station];
    id<MKMID> sid = [station ID];
    id<DKDContent> cmd;
    if (sessionKey) {
        // handshake again
        cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:sessionKey];
        [self sendContent:cmd sender:nil receiver:sid priority:-1];
    } else {
        // first handshake
        DIMCommonFacebook *facebook = [self facebook];
        id<MKMUser> user = [facebook currentUser];
        NSAssert(user, @"current user not found");
        id<MKMID> uid = [user ID];
        id<MKMMeta> meta = [user meta];
        id<MKMVisa> visa = [user visa];
        id<DKDEnvelope> env = DKDEnvelopeCreate(uid, sid, nil);
        cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:nil];
        // send first handshake command as broadcast message
        [cmd setGroup:MKMAnyStation()];
        // create instant message with meta & visa
        id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, cmd);
        [iMsg setObject:meta.dictionary forKey:@"meta"];
        [iMsg setObject:visa.dictionary forKey:@"visa"];
        [self sendInstantMessage:iMsg priority:-1];
    }
}

- (void)handshakeSuccess {
    // broadcast current documents after handshake success
    [self broadcastDocument];
}

- (void)broadcastDocument {
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMUser> user = [facebook currentUser];
    NSAssert(user, @"current user not found");
    id<MKMID> uid = [user ID];
    id<MKMMeta> meta = [user meta];
    id<MKMVisa> visa = [user visa];
    id<DKDContent> cmd = [[DIMDocumentCommand alloc] initWithID:uid
                                                           meta:meta
                                                       document:visa];
    // broadcast to 'everyone@everywhere'
    [self sendContent:cmd sender:uid receiver:MKMEveryone() priority:1];
}

- (void)broadcastLoginForID:(id<MKMID>)sender userAgent:(nullable NSString *)ua {
    DIMClientSession *session = [self session];
    DIMStation *station = [session station];
    // create login command
    DIMLoginCommand *cmd = [[DIMLoginCommand alloc] initWithID:sender];
    [cmd setAgent:ua];
    [cmd copyStationInfo:station];
    // broadcast to 'everyone@everywhere'
    [self sendContent:cmd sender:sender receiver:MKMEveryone() priority:1];
}

- (void)reportOnlineForID:(id<MKMID>)sender {
    id<DKDContent> cmd = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Online];
    NSDate *offlineTime = self.offlineTime;
    if (offlineTime) {
        NSTimeInterval ti = OKGetTimeInterval(offlineTime);
        [cmd setObject:@(ti) forKey:@"last_time"];
    }
    [self sendContent:cmd sender:sender receiver:MKMAnyStation() priority:1];
}

- (void)reportOfflineForID:(id<MKMID>)sender {
    id<DKDContent> cmd = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Offline];
    NSDate *offlineTime = [cmd time];
    if (offlineTime) {
        self.offlineTime = offlineTime;
    }
    [self sendContent:cmd sender:sender receiver:MKMAnyStation() priority:1];
}

// Override
- (BOOL)queryMetaForID:(id<MKMID>)ID {
    DIMQueryFrequencyChecker *checker = [DIMQueryFrequencyChecker sharedInstance];
    if ([checker checkMetaForID:ID isExpired:0]) {
        // query not expired yet
        return NO;
    }
    id<DKDCommand> cmd = [[DIMMetaCommand alloc] initWithID:ID];
    [self sendContent:cmd sender:nil receiver:MKMAnyStation() priority:1];
    return YES;
}

// Override
- (BOOL)queryDocumentForID:(id<MKMID>)ID {
    DIMQueryFrequencyChecker *checker = [DIMQueryFrequencyChecker sharedInstance];
    if ([checker checkDocumentForID:ID isExpired:0]) {
        // query not expired yet
        return NO;
    }
    id<DKDCommand> cmd = [[DIMDocumentCommand alloc] initWithID:ID];
    [self sendContent:cmd sender:nil receiver:MKMAnyStation() priority:1];
    return NO;
}

- (BOOL)queryMembersForID:(id<MKMID>)group {
    DIMQueryFrequencyChecker *checker = [DIMQueryFrequencyChecker sharedInstance];
    if ([checker checkMembersForID:group isExpired:0]) {
        // query not expired yet
        return NO;
    }
    NSAssert(MKMIDIsGroup(group), @"group ID error: %@", group);
    NSArray<id<MKMID>> *bots = [self.facebook assistantsOfGroup:group];
    if ([bots count] == 0) {
        // group assistants not found
        return NO;
    }
    // querying members from bots
    id<DKDCommand> cmd = [[DIMQueryGroupCommand alloc] initWithGroup:group];
    for (id<MKMID> assistant in bots) {
        [self sendContent:cmd sender:nil receiver:assistant priority:1];
    }
    return YES;
}

// Override
- (BOOL)checkReceiverForMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = [iMsg receiver];
    if (MKMIDIsBroadcast(receiver)) {
        // broadcast message
        return YES;
    } else if (MKMIDIsGroup(receiver)) {
        DIMCommonFacebook *facebook = [self facebook];
        // check group's meta
        id<MKMMeta> meta = [facebook metaForID:receiver];
        if (!meta) {
            // group not ready, try to query meta for it
            if ([self queryMetaForID:receiver]) {
                NSLog(@"querying meta for group: %@", receiver);
            }
            NSDictionary *error = @{
                @"message": @"group meta not found",
                @"group": receiver.string,
            };
            [self suspendInstantMessage:iMsg errorInfo:error];
            //[iMsg setObject:error forKey:@"error"];
            return NO;
        }
        // check group members
        NSArray<id<MKMID>> *members = [facebook membersOfGroup:receiver];
        if ([members count] == 0) {
            // group not ready, try to query members for it
            if ([self queryMembersForID:receiver]) {
                NSLog(@"querying members for group: %@", receiver);
            }
            NSDictionary *error = @{
                @"message": @"members not found",
                @"group": receiver.string,
            };
            [self suspendInstantMessage:iMsg errorInfo:error];
            //[iMsg setObject:error forKey:@"error"];
            return NO;
        }
        NSMutableArray<id<MKMID>> *waiting = [[NSMutableArray alloc] init];
        id<MKMEncryptKey> visaKey;
        for (id<MKMID> item in members) {
            visaKey = [facebook publicKeyForEncryption:item];
            if (!visaKey) {
                // group member not ready, try to query document for it
                if ([self queryDocumentForID:item]) {
                    NSLog(@"querying visa for %@ in group %@", item, receiver);
                }
                [waiting addObject:item];
            }
        }
        if ([waiting count] > 0) {
            NSDictionary *error = @{
                @"message": @"encrypt keys not found",
                @"group": receiver.string,
                @"members": MKMIDRevert(waiting),
            };
            [self suspendInstantMessage:iMsg errorInfo:error];
            //[iMsg setObject:error forKey:@"error"];
            return NO;
        }
        // receiver is OK
        return YES;
    }
    return [super checkReceiverForMessage:iMsg];
}

@end
