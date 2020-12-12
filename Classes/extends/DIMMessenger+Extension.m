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

#import "DIMDefaultProcessor.h"
#import "DIMReceiptCommandProcessor.h"
#import "DIMHandshakeCommandProcessor.h"
#import "DIMLoginCommandProcessor.h"
#import "DIMMuteCommandProcessor.h"
#import "DIMSearchCommandProcessor.h"
#import "DIMStorageCommandProcessor.h"

#import "DIMAmanuensis.h"
#import "DIMFacebook+Extension.h"

#import "DIMMessenger+Extension.h"

NSString * const kNotificationName_MessageSent       = @"MessageSent";
NSString * const kNotificationName_SendMessageFailed = @"SendMessageFailed";

@interface _SharedMessenger : DIMMessenger {
    
    // query tables
    NSMutableDictionary<id<MKMID>, NSDate *> *_metaQueryTable;
    NSMutableDictionary<id<MKMID>, NSDate *> *_profileQueryTable;
    NSMutableDictionary<id<MKMID>, NSDate *> *_groupQueryTable;
}

@end

static inline void load_cmd_classes(void) {
    DIMCommandParserRegisterClass(DIMCommand_Search, DIMSearchCommand);
    DIMCommandParserRegisterClass(DIMCommand_OnlineUsers, DIMSearchCommand);
}

static inline void load_cpu_classes(void) {
    
    DIMContentProcessorRegisterClass(DKDContentType_Unknown, DIMDefaultContentProcessor);
    
    DIMCommandProcessorRegisterClass(DIMCommand_Receipt, DIMReceiptCommandProcessor);
    DIMCommandProcessorRegisterClass(DIMCommand_Handshake, DIMHandshakeCommandProcessor);
    DIMCommandProcessorRegisterClass(DIMCommand_Login, DIMLoginCommandProcessor);
    
    DIMCommandProcessorRegisterClass(DIMCommand_Mute, DIMMuteCommandProcessor);

    DIMStorageCommandProcessor *storeProcessor = [[DIMStorageCommandProcessor alloc] init];
    DIMCommandProcessorRegister(DIMCommand_Storage, storeProcessor);
    DIMCommandProcessorRegister(DIMCommand_Contacts, storeProcessor);
    DIMCommandProcessorRegister(DIMCommand_PrivateKey, storeProcessor);
    
    DIMSearchCommandProcessor *searchProcessor = [[DIMSearchCommandProcessor alloc] init];
    DIMCommandProcessorRegister(DIMCommand_Search, searchProcessor);
    DIMCommandProcessorRegister(DIMCommand_OnlineUsers, searchProcessor);
}

@implementation _SharedMessenger

SingletonImplementations(_SharedMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        self.barrack = [DIMFacebook sharedInstance];
        self.keyCache = nil;//[DIMKeyStore sharedInstance];
        
        // query tables
        _metaQueryTable    = [[NSMutableDictionary alloc] init];
        _profileQueryTable = [[NSMutableDictionary alloc] init];
        _groupQueryTable = [[NSMutableDictionary alloc] init];

        // register CPU classes
        SingletonDispatchOnce(^{
            load_cmd_classes();
            load_cpu_classes();
        });
    }
    return self;
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

#pragma mark -

@interface _MessageProcessor : DIMMessageProcessor

@end

@implementation _MessageProcessor

- (void)_attachKeyDigest:(id<DKDReliableMessage>)rMsg {
    if (rMsg.delegate == nil) {
        rMsg.delegate = self.messenger;
    }
    if ([rMsg encryptedKey]) {
        // 'key' exists
        return;
    }
    NSDictionary *keys = [rMsg encryptedKeys];
    if ([keys objectForKey:@"digest"]) {
        // key digest already exists
        return;
    }
    // get key with direction
    id<MKMSymmetricKey> key;
    id<MKMID>sender = rMsg.envelope.sender;
    id<MKMID>group = rMsg.envelope.group;
    if (group) {
        key = [self.keyCache cipherKeyFrom:sender to:group generate:NO];
    } else {
        id<MKMID>receiver = rMsg.envelope.receiver;
        key = [self.keyCache cipherKeyFrom:sender to:receiver generate:NO];
    }
    // get key data
    NSData *data = key.data;
    if ([data length] < 6) {
        if ([key.algorithm isEqualToString:@"PLAIN"]) {
            NSLog(@"broadcast message has no key: %@", rMsg);
            return;
        }
        NSAssert(false, @"key data error: %@", key);
        return;
    }
    // get digest
    NSRange range = NSMakeRange([data length] - 6, 6);
    NSData *part = [data subdataWithRange:range];
    NSData *digest = MKMSHA256Digest(part);
    NSString *base64 = MKMBase64Encode(digest);
    // set digest
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:keys];
    NSUInteger pos = base64.length - 8;
    [mDict setObject:[base64 substringFromIndex:pos] forKey:@"digest"];
    [rMsg setObject:mDict forKey:@"keys"];
}

#pragma mark Serialization

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    [self _attachKeyDigest:rMsg];
    return [super serializeMessage:rMsg];
}

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    if ([data length] == 0) {
        return nil;
    }
    return [super deserializeMessage:data];
}

#pragma mark Reuse message key

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    id<DKDSecureMessage> sMsg = [super encryptMessage:iMsg];
    id<DKDEnvelope> env = iMsg.envelope;
    id<MKMID> receiver = env.receiver;
    if (MKMIDIsGroup(receiver)) {
        // reuse group message keys
        id<MKMID> sender = env.sender;
        id<MKMSymmetricKey> key = [self.keyCache cipherKeyFrom:sender to:receiver generate:NO];
        [key setObject:@(YES) forKey:@"reused"];
    }
    // TODO: reuse personal message key?
    return sMsg;
}

#pragma mark Process

- (nullable id<DKDContent>)processContent:(id<DKDContent>)content
                              withMessage:(id<DKDReliableMessage>)rMsg {
    id<MKMID> sender = rMsg.sender;
    if ([self.messenger checkingGroup:content sender:sender]) {
        // save this message in a queue to wait group meta response
        [self.messenger suspendMessage:rMsg];
        return nil;
    }
    
    id<DKDContent>res = [super processContent:content withMessage:rMsg];
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
        id<MKMID>receiver = rMsg.envelope.receiver;
        if (MKMNetwork_IsStation(receiver.type)) {
            // no need to respond receipt to station
            return nil;
        }
    }
     */
    
    // check receiver
    id<MKMID>receiver = rMsg.envelope.receiver;
    MKMUser *user = [self.facebook selectLocalUserWithID:receiver];
    NSAssert(user, @"receiver error: %@", receiver);
    
    // pack message
    id<DKDEnvelope> env = DKDEnvelopeCreate(user.ID, sender, nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, res);
    // normal response
    [self.messenger sendInstantMessage:iMsg callback:NULL];
    // DON'T respond to station directly
    return nil;
}

@end

#pragma mark -

@implementation DIMMessenger (Extension)

+ (instancetype)sharedInstance {
    return [_SharedMessenger sharedInstance];
}

static DIMStation *s_server = nil;

- (DIMStation *)currentServer {
    return s_server;
}

- (void)setCurrentServer:(DIMStation *)server {
    s_server = server;
}

- (BOOL)broadcastContent:(id<DKDContent>)content {
    NSAssert(self.currentServer, @"station not connected yet");
    // broadcast IDs
    id<MKMID>everyone = MKMIDFromString(@"everyone@everywhere");
    [content setGroup:everyone];
    return [self sendContent:content receiver:everyone callback:NULL];
}

- (BOOL)sendCommand:(DIMCommand *)cmd {
    DIMStation *server = [self currentServer];
    NSAssert(server, @"server not connected yet");
    return [self sendContent:cmd receiver:server.ID callback:NULL];
}

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryProfileForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMember:(id<MKMID>)member {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMembers:(NSArray<id<MKMID>> *)members {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)postProfile:(id<MKMDocument>)profile {
    MKMUser *user = [self.facebook currentUser];
    id<MKMID>ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    
    id<MKMMeta>meta = user.meta;
    if (![profile verify:meta.key]){
        return NO;
    }
    
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID
                                                     profile:profile];
    return [self sendCommand:cmd];
}

- (BOOL)broadcastProfile:(id<MKMDocument>)profile {
    MKMUser *user = [self.facebook currentUser];
    id<MKMID>ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return NO;
    }
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID
                                                     profile:profile];
    NSArray<id<MKMID>> *contacts = user.contacts;
    BOOL OK = YES;
    for (id<MKMID>contact in contacts) {
        if (!MKMIDIsUser(contact)) {
            NSLog(@"%@ is not a user, do not broadcaset profile to it", contact);
            continue;
        }
        if (![self sendContent:cmd receiver:contact callback:NULL]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)postContacts:(NSArray<id<MKMID>> *)contacts {
    MKMUser *user = [self.facebook currentUser];
    NSAssert([contacts count] > 0, @"contacts cannot be empty");
    // generate password
    id<MKMSymmetricKey>password = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
    // encrypt contacts
    NSData *data = MKMJSONEncode(contacts);
    data = [password encrypt:data];
    // encrypt key
    NSData *key = MKMJSONEncode(password);
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
    MKMUser *user = [self.facebook currentUser];
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

- (BOOL)_isEmptyGroup:(id<MKMID>)group {
    NSArray *members = [self.facebook membersOfGroup:group];
    if ([members count] == 0) {
        return YES;
    }
    id<MKMID>owner = [self.facebook ownerOfGroup:group];
    return !owner;
}

// check whether need to update group
- (BOOL)checkingGroup:(id<DKDContent>)content sender:(id<MKMID>)sender {
    // Check if it is a group message, and whether the group members info needs update
    id<MKMID>group = content.group;
    if (!group || MKMIDIsBroadcast(group)) {
        // 1. personal message
        // 2. broadcast message
        return NO;
    }
    // chek meta for new group ID
    id<MKMMeta>meta = [self.facebook metaForID:group];
    if (!meta) {
        // NOTICE: if meta for group not found,
        //         facebook should query it from DIM network automatically
        // TODO: insert the message to a temporary queue to wait meta
        //NSAssert(false, @"group meta not found: %@", group);
        return YES;
    }
    // query group command
    if ([self _isEmptyGroup:group]) {
        // NOTICE: if the group info not found, and this is not an 'invite' command
        //         query group info from the sender
        if ([content isKindOfClass:[DIMInviteCommand class]] ||
            [content isKindOfClass:[DIMResetGroupCommand class]]) {
            // FIXME: can we trust this stranger?
            //        may be we should keep this members list temporary,
            //        and send 'query' to the owner immediately.
            // TODO: check whether the members list is a full list,
            //       it should contain the group owner(owner)
            return NO;
        } else {
            return [self queryGroupForID:group fromMember:sender];
        }
    } else if ([self.facebook group:group containsMember:sender] ||
               [self.facebook group:group containsAssistant:sender] ||
               [self.facebook group:group isOwner:sender]) {
        // normal membership
        return NO;
    } else {
        // if assistants exist, query them
        NSArray<id<MKMID>> *assistants = [self.facebook assistantsOfGroup:group];
        NSMutableArray<id<MKMID>> *mArray = [[NSMutableArray alloc] initWithCapacity:(assistants.count+1)];
        for (id<MKMID>item in assistants) {
            [mArray addObject:item];
        }
        // if owner found, query it
        id<MKMID>owner = [self.facebook ownerOfGroup:group];
        if (owner && ![mArray containsObject:owner]) {
            [mArray addObject:owner];
        }
        return [self queryGroupForID:group fromMembers:mArray];
    }
}

@end
