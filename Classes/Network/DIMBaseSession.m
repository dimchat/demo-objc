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
//  DIMBaseSession.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBaseSession.h"

@interface DIMSession ()

@property(nonatomic, strong) id<DIMSessionDBI> database;

@property(nonatomic, strong) id<MKMID> identifier;

@end

@implementation DIMSession

- (instancetype)initWithRemoteAddress:(id<NIOSocketAddress>)remote
                        socketChannel:(NIOSocketChannel *)sock {
    NSAssert(false, @"DON'T call me!");
    id<DIMSessionDBI> db = nil;
    return [self initWithDatabase:db remoteAddress:remote socketChannel:sock];
}

/* designated initializer */
- (instancetype)initWithDatabase:(id<DIMSessionDBI>)db
                   remoteAddress:(id<NIOSocketAddress>)remote
                   socketChannel:(NIOSocketChannel *)sock {
    if (self = [super initWithRemoteAddress:remote socketChannel:sock]) {
        self.database = db;
        self.identifier = nil;
        self.messenger = nil;
    }
    return self;
}

// Override
- (NSString *)key {
    NSAssert(false, @"override me!");
    return nil;
}

// Override
- (id<MKMID>)ID {
    return _identifier;
}

// Override
- (BOOL)setID:(id<MKMID>)user {
    if (!_identifier) {
        if (!user) {
            return NO;
        }
    } else if ([_identifier isEqual:user]) {
        return NO;
    }
    self.identifier = user;
    return YES;
}

// Override
- (BOOL)queueMessage:(id<DKDReliableMessage>)rMsg package:(NSData *)data
            priority:(NSInteger)prior {
    id<STDeparture> ship = [self departureByPackData:data priority:prior];
    return [self appendReliableMessage:rMsg departureShip:ship];
}

//
//  Transmitter
//

// Override
- (DIMTransmitterResults *)sendContent:(id<DKDContent>)content
                                sender:(nullable id<MKMID>)from
                              receiver:(id<MKMID>)to
                              priority:(NSInteger)prior {
    NSAssert(_messenger, @"messenger not set yet");
    return [_messenger sendContent:content sender:from receiver:to priority:prior];
}

// Override
- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior {
    NSAssert(_messenger, @"messenger not set yet");
    return [_messenger sendInstantMessage:iMsg priority:prior];
}

// Override
- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg priority:(NSInteger)prior {
    NSAssert(_messenger, @"messenger not set yet");
    return [_messenger sendReliableMessage:rMsg priority:prior];
}

//
//  Docker Delegate
//

// Override
- (void)docker:(id<STDocker>)worker sentShip:(id<STDeparture>)departure {
    if ([departure isKindOfClass:[DIMMessageWrapper class]]) {
        DIMMessageWrapper *wrapper = (DIMMessageWrapper *)departure;
        id<DKDReliableMessage> rMsg = [wrapper message];
        if (rMsg) {
            // remove from database for actual receiver
            [self removeReliableMessage:rMsg];
        }
    }
}

// private
- (void)removeReliableMessage:(id<DKDReliableMessage>)rMsg {
    // 0. if session ID is empty, means user not login;
    //    this message must be a handshake command, and
    //    its receiver must be the targeted user.
    // 1. if this session is a station, check original receiver;
    //    a message to station won't be stored.
    // 2. if the msg.receiver is a different user ID, means it's
    //    a roaming message, remove it for actual receiver.
    // 3. if the original receiver is a group, it must had been
    //    replaced to the group assistant ID by GroupDeliver.
    id<MKMID> receiver = [self ID];
    if (!receiver || [receiver type] == MKMEntityType_Station) {
        //if ([[rMsg receiver] isEqual:receiver]) {
        //    // staion message won't be stored
        //    return;
        //}
        receiver = [rMsg receiver];
    }
    id<DIMMessageDBI> db = [_messenger database];
    [db removeReliableMessage:rMsg forReceiver:receiver];
}

@end
