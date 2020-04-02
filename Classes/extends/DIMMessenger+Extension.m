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
#import "NSData+Crypto.h"

#import "DIMSearchCommand.h"

#import "DIMHandshakeCommandProcessor.h"
#import "DIMReceiptCommandProcessor.h"
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

@interface _SharedMessenger : DIMMessenger {
    
    // query tables
    NSMutableDictionary<DIMID *, NSDate *> *_metaQueryTable;
    NSMutableDictionary<DIMID *, NSDate *> *_profileQueryTable;
    NSMutableDictionary<DIMID *, NSDate *> *_groupQueryTable;
}

@end

static inline void load_cmd_classes(void) {
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_Search];
    [DIMCommand registerClass:[DIMSearchCommand class] forCommand:DIMCommand_OnlineUsers];
}

static inline void load_cpu_classes(void) {
    
    [DIMCommandProcessor registerClass:[DIMHandshakeCommandProcessor class] forCommand:DIMCommand_Handshake];
    
    [DIMCommandProcessor registerClass:[DIMReceiptCommandProcessor class]
                            forCommand:DIMCommand_Receipt];

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

- (BOOL)queryMetaForID:(DIMID *)ID {
    if ([ID isBroadcast]) {
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

- (BOOL)queryProfileForID:(DIMID *)ID {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_profileQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < 30) {
        return NO;
    }
    [_profileQueryTable setObject:now forKey:ID];
    
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)queryGroupForID:(DIMID *)group fromMember:(DIMID *)member {
    return [self queryGroupForID:group fromMembers:@[member]];
}

- (BOOL)queryGroupForID:(DIMID *)group fromMembers:(NSArray<DIMID *> *)members {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_groupQueryTable objectForKey:group];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < 30) {
        return NO;
    }
    [_groupQueryTable setObject:now forKey:group];
    
    DIMCommand *cmd = [[DIMQueryGroupCommand alloc] initWithGroup:group];
    BOOL checking = NO;
    for (DIMID *item in members) {
        if ([self sendContent:cmd receiver:item]) {
            checking = YES;
        }
    }
    return checking;
}

- (BOOL)_isEmptyGroup:(DIMID *)group {
    NSArray *members = [self.facebook membersOfGroup:group];
    if ([members count] == 0) {
        return YES;
    }
    DIMID *owner = [self.facebook ownerOfGroup:group];
    return !owner;
}

// check whether need to update group
- (BOOL)_checkingGroup:(DIMContent *)content sender:(DIMID *)sender {
    // Check if it is a group message, and whether the group members info needs update
    DIMID *group = [self.facebook IDWithString:content.group];
    if (!group || [group isBroadcast]) {
        // 1. personal message
        // 2. broadcast message
        return NO;
    }
    // chek meta for new group ID
    DIMMeta *meta = [self.facebook metaForID:group];
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
    } else if ([self.facebook group:group hasMember:sender] ||
               [self.facebook group:group hasAssistant:sender] ||
               [self.facebook group:group isOwner:sender]) {
        // normal membership
        return NO;
    } else {
        // if assistants exist, query them
        NSArray<DIMID *> *assistants = [self.facebook assistantsOfGroup:group];
        NSMutableArray<DIMID *> *mArray = [[NSMutableArray alloc] initWithCapacity:(assistants.count+1)];
        for (DIMID *item in assistants) {
            [mArray addObject:item];
        }
        // if owner found, query it
        DIMID *owner = [self.facebook ownerOfGroup:group];
        if (owner && ![mArray containsObject:owner]) {
            [mArray addObject:owner];
        }
        return [self queryGroupForID:group fromMembers:mArray];
    }
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
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:name object:self userInfo:info];
    };
    return [self sendContent:content receiver:receiver callback:callback];
}

#pragma mark Serialization

- (nullable NSData *)serializeMessage:(DIMReliableMessage *)rMsg {
    [self _attachKeyDigest:rMsg];
    return [super serializeMessage:rMsg];
}

- (void)_attachKeyDigest:(DIMReliableMessage *)rMsg {
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
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
    DIMSymmetricKey *key;
    DIMID *sender = [self.barrack IDWithString:rMsg.envelope.sender];
    DIMID *group = [self.barrack IDWithString:rMsg.envelope.group];
    if (group) {
        key = [self.keyCache cipherKeyFrom:sender to:group];
    } else {
        DIMID *receiver = [self.barrack IDWithString:rMsg.envelope.receiver];
        key = [self.keyCache cipherKeyFrom:sender to:receiver];
    }
    // get key data
    NSData *data = key.data;
    if ([data length] < 6) {
        NSAssert(false, @"key data error: %@", key);
        return;
    }
    // get digest
    NSRange range = NSMakeRange([data length] - 6, 6);
    NSData *part = [data subdataWithRange:range];
    NSData *digest = [part sha256];
    NSString *base64 = [digest base64Encode];
    // set digest
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:keys];
    NSUInteger pos = base64.length - 8;
    [mDict setObject:[base64 substringFromIndex:pos] forKey:@"digest"];
    [rMsg setObject:mDict forKey:@"keys"];
}

- (nullable DIMReliableMessage *)deserializeMessage:(NSData *)data {
    if ([data length] == 0) {
        return nil;
    }
    return [super deserializeMessage:data];
}

#pragma mark - Reuse message key

- (nullable DIMSecureMessage *)encryptMessage:(DIMInstantMessage *)iMsg {
    DIMSecureMessage *sMsg = [super encryptMessage:iMsg];
    DIMEnvelope *env = iMsg.envelope;
    DIMID *receiver = [self.facebook IDWithString:env.receiver];
    if ([receiver isGroup]) {
        // reuse group message keys
        DIMID *sender = [self.facebook IDWithString:env.sender];
        DIMSymmetricKey *key = [self.keyCache cipherKeyFrom:sender to:receiver];
        [key setObject:@(YES) forKey:@"reused"];
    }
    // TODO: reuse personal message key?
    return sMsg;
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                serializeKey:(NSDictionary *)password {
    if ([password objectForKey:@"reused"]) {
        // no need to encrypt reused key again
        return nil;
    }
    return [super message:iMsg serializeKey:password];
}

#pragma mark - Message

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
    if ([content isKindOfClass:[DIMForwardContent class]]) {
        // forward content will be parsed, if secret message decrypted, save it
        // no need to save forward content itself
        return YES;
    }
    
    if ([content isKindOfClass:[DIMInviteCommand class]]) {
        // send keys again
        DIMID *me = DIMIDWithString(iMsg.envelope.receiver);
        DIMID *group = DIMIDWithString([content group]);
        DIMSymmetricKey *key = [self.keyCache cipherKeyFrom:me to:group];
        [key removeObjectForKey:@"reused"];
        NSLog(@"key (%@ => %@): %@", me, group, key);
    }
    if ([content isKindOfClass:[DIMQueryGroupCommand class]]) {
        // FIXME: same query command sent to different members?
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

- (nullable DIMInstantMessage *)processInstantMessage:(DIMInstantMessage *)iMsg {
    DIMContent *content = iMsg.content;
    DIMID *sender = [self.facebook IDWithString:iMsg.envelope.sender];
    
    if ([self _checkingGroup:content sender:sender]) {
        // save this message in a queue to wait group meta response
        [self suspendMessage:iMsg];
        return nil;
    }
    
    iMsg = [super processInstantMessage:iMsg];
    if (!iMsg) {
        // respond nothing
        return nil;
    }
    if ([iMsg.content isKindOfClass:[DIMHandshakeCommand class]]) {
        // urgent command
        return iMsg;
    }
    /*
    if ([iMsg.content isKindOfClass:[DIMReceiptCommand class]]) {
        DIMID *receiver = [self.barrack IDWithString:rMsg.envelope.receiver];
        if (MKMNetwork_IsStation(receiver.type)) {
            // no need to respond receipt to station
            return nil;
        }
    }
     */
    // normal response
    [self sendInstantMessage:iMsg];
    // DON'T respond to station directly
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
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryProfileForID:(DIMID *)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(DIMID *)group fromMember:(DIMID *)member {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(DIMID *)group fromMembers:(NSArray<DIMID *> *)members {
    NSAssert(false, @"implement me!");
    return NO;
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
        if (![contact isUser]) {
            NSLog(@"%@ is not a user, do not broadcaset profile to it", contact);
            continue;
        }
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
