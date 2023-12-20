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
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"
#import "DIMReportCommand.h"
#import "DIMGroupManager.h"
#import "DIMClientSession.h"
#import "DIMClientArchivist.h"

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
        [self sendContent:cmd
                   sender:nil
                 receiver:sid
                 priority:STDeparturePriorityUrgent];
        NSLog(@"shake hands again with session key %@, %@", sessionKey, station);
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
        [cmd setGroup:MKMEveryStations()];
        // create instant message with meta & visa
        id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, cmd);
        DIMMessageSetMeta(meta, iMsg);
        DIMMessageSetVisa(visa, iMsg);
        [self sendInstantMessage:iMsg
                        priority:STDeparturePriorityUrgent];
        NSLog(@"shaking hands with %@", station);
    }
}

- (void)handshakeSuccess {
    // broadcast current documents after handshake success
    [self broadcastDocument:NO];
}

- (void)broadcastDocument:(BOOL)updated {
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMUser> user = [facebook currentUser];
    NSAssert(user, @"current user not found");
    id<MKMID> uid = [user ID];
    id<MKMMeta> meta = [user meta];
    id<MKMVisa> visa = [user visa];
    id<DKDContent> command = [[DIMDocumentCommand alloc] initWithID:uid
                                                               meta:meta
                                                           document:visa];
    DIMClientArchivist *archivist = [self.facebook archivist];
    //
    //  send to all contacts
    //
    NSArray<id<MKMID>> *contacts = [self.facebook contactsOfUser:uid];
    for (id<MKMID> item in contacts) {
        if ([archivist isDocumentResponseExpired:item force:updated]) {
            NSLog(@"sending visa to: %@", item);
            [self sendContent:command sender:uid receiver:item priority:1];
        } else {
            // not expired yet
            NSLog(@"visa response not expired yet: %@ => %@", uid, item);
        }
    }
    //
    //  broadcast to 'everyone@everywhere'
    //
    id<MKMID> everyone = MKMEveryone();
    if ([archivist isDocumentResponseExpired:everyone force:updated]) {
        NSLog(@"sending visa to %@", everyone);
        [self sendContent:command sender:uid receiver:everyone priority:1];
    } else {
        // not expired yet
        NSLog(@"visa response not expired yet: %@ => %@", uid, everyone);
    }
}

- (void)broadcastLogin:(id<MKMID>)sender userAgent:(nullable NSString *)ua {
    DIMClientSession *session = [self session];
    DIMStation *station = [session station];
    // create login command
    DIMLoginCommand *command = [[DIMLoginCommand alloc] initWithID:sender];
    [command setAgent:ua];
    [command copyStationInfo:station];
    // broadcast to 'everyone@everywhere'
    [self sendContent:command
               sender:sender
             receiver:MKMEveryone()
             priority:STDeparturePrioritySlower];
}

- (void)reportOnline:(id<MKMID>)sender {
    id<DKDContent> command = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Online];
    NSDate *offlineTime = self.offlineTime;
    if (offlineTime) {
        NSTimeInterval ti = OKGetTimeInterval(offlineTime);
        [command setObject:@(ti) forKey:@"last_time"];
    }
    [self sendContent:command
               sender:sender
             receiver:MKMAnyStation()
             priority:STDeparturePrioritySlower];
}

- (void)reportOffline:(id<MKMID>)sender {
    id<DKDContent> command = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Offline];
    NSDate *offlineTime = [command time];
    if (offlineTime) {
        self.offlineTime = offlineTime;
    }
    [self sendContent:command
               sender:sender
             receiver:MKMAnyStation()
             priority:STDeparturePrioritySlower];
}

@end
