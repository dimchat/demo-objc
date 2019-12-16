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
#import "NSObject+JsON.h"
#import "NSNotificationCenter+Extension.h"

#import "DIMSearchCommand.h"

#import "DIMHandshakeCommandProcessor.h"
#import "DIMMuteCommandProcessor.h"
#import "DIMSearchCommandProcessor.h"
#import "DIMStorageCommandProcessor.h"

#import "DIMAmanuensis.h"
#import "DIMFacebook+Extension.h"

#import "DIMMessenger+Extension.h"

NSString * const kNotificationName_MessageSent       = @"MessageSent";
NSString * const kNotificationName_SendMessageFailed = @"SendMessageFailed";

@interface DIMKeyStore (Extension)

+ (instancetype)sharedInstance;

@end

@implementation DIMKeyStore (Extension)

SingletonImplementations(DIMKeyStore, sharedInstance)

@end

#pragma mark -

@interface _SharedMessenger : DIMMessenger

@end

static inline void load_cmd_classes(void) {
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_Search];
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_OnlineUsers];
}

static inline void load_cpu_classes(void) {
    
    [DIMCommandProcessor registerClass:[DIMHandshakeCommandProcessor class] forCommand:DIMCommand_Handshake];
    
    [DIMCommandProcessor registerClass:[DIMMuteCommandProcessor class] forCommand:DIMCommand_Mute];
    
    [DIMCommandProcessor registerClass:[DIMSearchCommandProcessor class] forCommand:DIMCommand_Search];
    [DIMCommandProcessor registerClass:[DIMSearchCommandProcessor class] forCommand:DIMCommand_OnlineUsers];
    
    [DIMCommandProcessor registerClass:[DIMStorageCommandProcessor class] forCommand:DIMCommand_Storage];
    [DIMCommandProcessor registerClass:[DIMStorageCommandProcessor class] forCommand:DIMCommand_Contacts];
    [DIMCommandProcessor registerClass:[DIMStorageCommandProcessor class] forCommand:DIMCommand_PrivateKey];
}

@implementation _SharedMessenger

SingletonImplementations(_SharedMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        self.barrack = [DIMFacebook sharedInstance];
        self.keyCache = [DIMKeyStore sharedInstance];
        
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cmd_classes();
            load_cpu_classes();
        });
    }
    return self;
}

- (BOOL)sendContent:(DIMContent *)content receiver:(DIMID *)receiver {
    DIMMessengerCallback callback;
    callback = ^(DIMReliableMessage *rMsg, NSError *error) {
        NSString *name = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            content.state = DIMMessageState_Error;
            content.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", content, rMsg);
            name = kNotificationName_MessageSent;
            content.state = DIMMessageState_Accepted;
        }
        
        NSDictionary *info = @{@"content": content};
        [NSNotificationCenter postNotificationName:name
                                            object:self
                                          userInfo:info];
    };
    return [self sendContent:content receiver:receiver callback:callback dispersedly:YES];
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

- (BOOL)suspendMessage:(DIMMessage *)msg {
    if ([msg isKindOfClass:[DIMReliableMessage class]]) {
        // TODO: save this message in a queue waiting sender's meta response
    } else {
        NSAssert([msg isKindOfClass:[DIMInstantMessage class]], @"message error: %@", msg);
        // TODO: save this message in a queue waiting receiver's meta response
    }
    return NO;
}

- (nullable DIMContent *)processMessage:(DIMReliableMessage *)rMsg {
    DIMContent *res = [super processMessage:rMsg];
    if (!res) {
        // respond nothing
        return nil;
    }
    if ([res isKindOfClass:[DIMHandshakeCommand class]]) {
        // urgent command
        return res;
    }
    /*
    if ([res isKindOfClass:[DIMReceiptCommand class]]) {
        DIMID *receiver = [self.barrack IDWithString:rMsg.envelope.receiver];
        if (MKMNetwork_IsStation(receiver.type)) {
            // no need to respond receipt to station
            return nil;
        }
    }
     */
    // normal response
    DIMID *receiver = [self.facebook IDWithString:rMsg.envelope.sender];
    [self sendContent:res receiver:receiver];
    // DNO'T respond station directly
    return nil;
}

@end

#pragma mark -

@implementation DIMMessenger (Extension)

+ (instancetype)sharedInstance {
    return [_SharedMessenger sharedInstance];
}

- (nullable DIMStation *)currentServer {
    return [self valueForContextName:@"server"];
}

- (BOOL)broadcastContent:(DIMContent *)content {
    NSAssert(self.currentServer, @"station not connected yet");
    // broadcast IDs
    DIMID *everyone = DIMIDWithString(@"everyone@everywhere");
    DIMID *anyone = DIMIDWithString(@"anyone@anywhere");
    [content setGroup:everyone];
    return [self sendContent:content receiver:anyone];
}

- (BOOL)sendCommand:(DIMCommand *)cmd {
    DIMStation *server = [self currentServer];
    NSAssert(server, @"server not connected yet");
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

- (BOOL)queryProfileForID:(DIMID *)ID {
    if ([ID isBroadcast]) {
        return YES;
    }
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)postProfile:(DIMProfile *)profile {
    DIMUser *user = [self.facebook currentUser];
    DIMID *ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    
    DIMMeta *meta = user.meta;
    if (![profile verify:meta.key]){
        return NO;
    }
    
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID
                                                    profile:profile];
    return [self sendCommand:cmd];
}

- (BOOL)broadcastProfile:(DIMProfile *)profile {
    DIMUser *user = [self.facebook currentUser];
    DIMID *ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID
                                                    profile:profile];
    NSArray<DIMID *> *contacts = user.contacts;
    BOOL OK = YES;
    for (DIMID *contact in contacts) {
        if (![self sendContent:cmd receiver:contact]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)postContacts:(NSArray<DIMID *> *)contacts {
    DIMUser *user = [self.facebook currentUser];
    NSAssert([contacts count] > 0, @"contacts cannot be empty");
    // generate password
    DIMSymmetricKey *password = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
    // encrypt contacts
    NSData *data = [contacts jsonData];
    data = [password encrypt:data];
    // encrypt key
    NSData *key = [password jsonData];
    key = [user encrypt:key];
    // pack 'contacts' command
    DIMStorageCommand *cmd;
    cmd = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    cmd.ID = user.ID;
    cmd.data = data;
    cmd.key = key;
    // send to station
    return [self sendCommand:cmd];
}

- (BOOL)queryContacts{
    DIMUser *user = [self.facebook currentUser];
    // pack 'contacts' command
    DIMStorageCommand *cmd;
    cmd = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    cmd.ID = user.ID;
    // send to station
    return [self sendCommand:cmd];
}

- (BOOL)queryMuteList{
    DIMCommand *cmd = [[DIMMuteCommand alloc] initWithList:nil];
    return [self sendCommand:cmd];
}

- (BOOL)queryOnlineUsers {
    DIMCommand *cmd = [[DIMSearchCommand alloc] initWithKeywords:DIMCommand_OnlineUsers];
    return [self sendCommand:cmd];
}

- (BOOL)searchUsersWithKeywords:(NSString *)keywords {
    DIMCommand *cmd = [[DIMSearchCommand alloc] initWithKeywords:keywords];
    return [self sendCommand:cmd];
}

@end
