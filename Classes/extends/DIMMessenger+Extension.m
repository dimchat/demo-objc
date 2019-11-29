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
//  DIMMessenger+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMSearchCommand.h"

#import "DIMHandshakeCommandProcessor.h"
#import "DIMSearchCommandProcessor.h"

#import "DIMAmanuensis.h"

#import "DIMMessenger+Extension.h"

@interface DIMSharedMessenger : DIMMessenger

@end

static inline void load_cmd_classes(void) {
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_Search];
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_OnlineUsers];
}

static inline void load_cpu_classes(void) {
    
    [DIMCommandProcessor registerClass:[DIMHandshakeCommandProcessor class] forCommand:DIMCommand_Handshake];
    
    [DIMCommandProcessor registerClass:[DIMSearchCommandProcessor class] forCommand:DIMCommand_Search];
    [DIMCommandProcessor registerClass:[DIMSearchCommandProcessor class] forCommand:DIMCommand_OnlineUsers];
}

@implementation DIMSharedMessenger

SingletonImplementations(DIMSharedMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cmd_classes();
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
    if ([content isKindOfClass:[DIMSearchCommand class]]) {
        // search result will be parsed by CPUs
        // no need to save search command here
        return YES;
    }
    
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    
    if ([content isKindOfClass:[DIMReceiptCommand class]]) {
        return [clerk saveReceipt:iMsg];
    } else {
        return [clerk saveMessage:iMsg];
    }
}

@end

@implementation DIMMessenger (Extension)

+ (instancetype)sharedInstance {
    return [DIMSharedMessenger sharedInstance];
}

@end
