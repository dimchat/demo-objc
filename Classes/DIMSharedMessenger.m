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
//  DIMSharedMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/30.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMHandshakeCommandProcessor.h"

#import "DIMAmanuensis.h"

#import "DIMSharedMessenger.h"

static inline void load_cpu_classes(void) {
    [DIMCommandProcessor registerClass:[DIMHandshakeCommandProcessor class] forCommand:DIMCommand_Handshake];
}

@implementation DIMSharedMessenger

SingletonImplementations(DIMSharedMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cpu_classes();
        });
    }
    return self;
}

- (nullable DIMStation *)currentServer {
    return [self valueForContextName:@"server"];
}

- (BOOL)sendCommand:(DIMCommand *)cmd {
    DIMStation *server = [self currentServer];
    return [self sendContent:cmd receiver:server.ID];
}

- (BOOL)queryMetaForID:(DIMID *)ID {
    NSAssert(![[self currentServer].ID isEqual:ID], @"error: %@", ID);
    if ([ID isBroadcast]) {
        return YES;
    }
    DIMCommand *cmd = [[DIMMetaCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (nullable DIMContent *)broadcastMessage:(DIMReliableMessage *)rMsg {
    // do nothing
    return nil;
}

- (nullable DIMContent *)deliverMessage:(DIMReliableMessage *)rMsg {
    // do nothing
    return nil;
}

- (BOOL)saveMessage:(DIMInstantMessage *)iMsg {
    DIMContent *content = iMsg.content;
    // TODO: check message type
    //       only save normal message and group commands
    //       ignore 'Handshake', ...
    //       return true to allow responding
    
    if ([content isKindOfClass:[DIMHandshakeCommand class]]) {
        // handshake command will be processed by CPUs
        // no need to save handshake command here
        return YES;
    }
    if ([content isKindOfClass:[DIMMetaCommand class]]) {
        // meta & profile command will be checked and saved by CPUs
        // no need to save meta & profile command here
        return YES;
    }
    if ([content isKindOfClass:[DIMMuteCommand class]] ||
        [content isKindOfClass:[DIMBlockCommand class]]) {
        // TODO: create CPUs for mute & block command
        // no need to save mute & block command here
        return YES;
    }
//    if ([content isKindOfClass:[DIMSearchCommand class]]) {
//        // search result will be parsed by CPUs
//        // no need to save search command here
//        return YES;
//    }
    
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    
    if ([content isKindOfClass:[DIMReceiptCommand class]]) {
        return [clerk saveReceipt:iMsg];
    } else {
        return [clerk saveMessage:iMsg];
    }
}

@end
