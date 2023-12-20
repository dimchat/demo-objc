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
//  DIMHandshakeCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/30.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMHandshakeCommand.h"

#import "DIMClientMessenger.h"
#import "DIMClientSession.h"

#import "DIMHandshakeCommandProcessor.h"

@implementation DIMHandshakeCommandProcessor

// Override
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDHandshakeCommand)], @"handshake error: %@", content);
    id<DKDHandshakeCommand> command = content;
    DIMClientMessenger *messenger = [self messenger];
    DIMClientSession *session = [messenger session];
    // update station's default ID ('station@anywhere') to sender (real ID)
    id<MKMStation> station = [session station];
    id<MKMID> old = [station ID];
    id<MKMID> sender = [rMsg sender];
    if (!old || [old isBroadcast]) {
        station.ID = sender;
    } else {
        NSAssert([old isEqual:sender], @"station ID not match: %@, %@", old, sender);
    }
    // handle handshake command with title & session key
    NSString *title = [command title];
    NSString *newKey = [command sessionKey];
    NSString *oldKey = [session key];
    NSAssert(newKey, @"new session key should not be empty: %@", command);
    if ([title isEqualToString:@"DIM?"]) {
        // S -> C: station ask client to handshake again
        if (!oldKey) {
            // first handshake response with new session key
            [messenger handshake:newKey];
        } else if ([oldKey isEqualToString:newKey]) {
            // duplicated handshake response?
            // or session expired and the station ask to handshake again?
            [messenger handshake:newKey];
        } else {
            // connection changed?
            // erase session key to handshake again
            [session setKey:nil];
        }
    } else if ([title isEqualToString:@"DIM!"]) {
        // S -> C: handshake accepted by station
        if (!oldKey) {
            // normal handshake response,
            // update session key to change state to 'running'
            [session setKey:newKey];
        } else if ([oldKey isEqualToString:newKey]) {
            // duplicated handshake response?
            NSLog(@"duplicated handshake response");
        } else {
            // FIXME: handshake error
            // erase session key to handshake again
            [session setKey:nil];
        }
    } else {
        // C -> S: Hello world!
        NSLog(@"handshake from other user? %@: %@", sender, content);
    }
    return nil;
}

@end
