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

#import "DIMServer.h"

#import "DIMMessenger+Extension.h"

#import "DIMHandshakeCommandProcessor.h"

@implementation DIMHandshakeCommandProcessor

- (NSArray<id<DKDContent>> *)success {
    DIMServer *server = (DIMServer *)[self.messenger currentServer];
    [server handshakeAccepted:YES];
    return nil;
}

- (NSArray<id<DKDContent>> *)ask:(NSString *)sessionKey {
    DIMServer *server = (DIMServer *)[self.messenger currentServer];
    [server handshakeWithSession:sessionKey];
    return nil;
}

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content isKindOfClass:[DIMHandshakeCommand class]], @"handshake error: %@", content);
    DIMHandshakeCommand *command = (DIMHandshakeCommand *)content;
    NSString *message = command.message;
    if ([message isEqualToString:@"DIM!"]) {
        // S -> C
        return [self success];
    } else if ([message isEqualToString:@"DIM?"]) {
        // S -> C
        return [self ask:command.sessionKey];
    } else {
        // C -> S: Hello world!
        NSAssert(false, @"handshake command error: %@", command);
        return nil;
    }
}

@end
