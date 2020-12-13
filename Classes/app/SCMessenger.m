// license: https://mit-license.org
//
//  SeChat : Secure/secret Chat Application
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  SCMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/13.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMSearchCommand.h"

#import "DIMAmanuensis.h"

#import "DIMFacebook+Extension.h"

#import "DIMMessenger+Extension.h"

#import "SCKeyStore.h"
#import "SCMessageProcessor.h"

#import "SCMessenger.h"

@implementation SCMessenger

SingletonImplementations(SCMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        self.barrack = [DIMFacebook sharedInstance];
        self.keyCache = [SCKeyStore sharedInstance];
        self.processor = [[SCMessageProcessor alloc] initWithMessenger:self];
        
        // query tables
        _metaQueryTable    = [[NSMutableDictionary alloc] init];
        _profileQueryTable = [[NSMutableDictionary alloc] init];
        _groupQueryTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (DIMStation *)currentServer {
    return _server;
}

- (void)setCurrentServer:(DIMStation *)server {
    _server = server;
}

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has not meta
        return YES;
    }
    
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_metaQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < 30) {
        return NO;
    }
    [_metaQueryTable setObject:now forKey:ID];
    
    DIMCommand *cmd = [[DIMMetaCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)queryProfileForID:(id<MKMID>)ID {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_profileQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < 30) {
        return NO;
    }
    [_profileQueryTable setObject:now forKey:ID];
    
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMember:(id<MKMID>)member {
    return [self queryGroupForID:group fromMembers:@[member]];
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMembers:(NSArray<id<MKMID>> *)members {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_groupQueryTable objectForKey:group];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < 30) {
        return NO;
    }
    [_groupQueryTable setObject:now forKey:group];
    
    DIMCommand *cmd = [[DIMQueryGroupCommand alloc] initWithGroup:group];
    BOOL checking = NO;
    for (id<MKMID>item in members) {
        if ([self sendContent:cmd receiver:item]) {
            checking = YES;
        }
    }
    return checking;
}

- (BOOL)sendContent:(id<DKDContent>)content receiver:(id<MKMID>)receiver {
    DKDContent *cont = (DKDContent *)content;
    DIMMessengerCallback callback = ^(id<DKDReliableMessage> rMsg, NSError *error) {
        NSString *name = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            cont.state = DIMMessageState_Error;
            cont.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", content, rMsg);
            name = kNotificationName_MessageSent;
            cont.state = DIMMessageState_Accepted;
        }
        
        NSDictionary *info = @{@"content": content};
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:name object:self userInfo:info];
    };
    return [self sendContent:content receiver:receiver callback:callback];
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    if ([password objectForKey:@"reused"]) {
        id<MKMID> receiver = iMsg.receiver;
        if (MKMIDIsGroup(receiver)) {
            // reuse key for grouped message
            return nil;
        }
    }
    return [super message:iMsg serializeKey:password];
}

#pragma mark Storage

- (BOOL)saveMessage:(id<DKDInstantMessage>)iMsg {
    id<DKDContent> content = iMsg.content;
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
    if ([content isKindOfClass:[DIMForwardContent class]]) {
        // forward content will be parsed, if secret message decrypted, save it
        // no need to save forward content itself
        return YES;
    }
    
    if ([content isKindOfClass:[DIMInviteCommand class]]) {
        // send keys again
        id<MKMID>me = iMsg.envelope.receiver;
        id<MKMID>group = content.group;
        id<MKMSymmetricKey>key = [self.keyCache cipherKeyFrom:me to:group generate:NO];
        [key removeObjectForKey:@"reused"];
        NSLog(@"key (%@ => %@): %@", me, group, key);
    }
    if ([content isKindOfClass:[DIMQueryGroupCommand class]]) {
        // FIXME: same query command sent to different members?
        return YES;
    }
    
    if ([content isKindOfClass:[DIMStorageCommand class]]) {
        return YES;
    }
    
    //Check whether is a command
    if ([content isKindOfClass:[DIMLoginCommand class]]) {
        return YES;
    }
    
    if([content isKindOfClass:[DIMCommand class]]){
        DIMCommand *command = (DIMCommand *)content;
        if([command.command isEqualToString:@"broadcast"]){
            NSLog(@"It is a broadcast command, skip : %@", content);
            return YES;
        }
    }
    
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    
    if ([content isKindOfClass:[DIMReceiptCommand class]]) {
        return [clerk saveReceipt:iMsg];
    } else {
        return [clerk saveMessage:iMsg];
    }
}

- (BOOL)suspendMessage:(id<DKDMessage>)msg {
    if ([msg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        // TODO: save this message in a queue waiting sender's meta response
    } else if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        // TODO: save this message in a queue waiting receiver's meta response
    }
    return NO;
}

@end
