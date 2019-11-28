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
//  DIMMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSObject+Singleton.h"
#import "DKDInstantMessage+Extension.h"
#import "DIMReceiptCommand.h"
#import "DIMMuteCommand.h"
#import "DIMBlockCommand.h"

#import "DIMFacebook.h"
#import "DIMKeyStore.h"

#import "DIMMessenger.h"

static inline void loadCommandClasses(void) {
    // register new command classes
    [DIMCommand registerClass:[DIMReceiptCommand class] forCommand:DIMCommand_Receipt];
    [DIMCommand registerClass:[DIMMuteCommand class] forCommand:DIMCommand_Mute];
    [DIMCommand registerClass:[DIMBlockCommand class] forCommand:DIMCommand_Block];
}

@interface DIMMessenger () {
    
    NSMutableDictionary *_context;
    
    __weak id<DIMMessengerDelegate> _delegate;
}

@end

@implementation DIMMessenger

SingletonImplementations(DIMMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
        
        // context
        _context = [[NSMutableDictionary alloc] init];
        
        _delegate = nil;
        
        // extend new commands
        loadCommandClasses();
    }
    return self;
}

- (NSDictionary *)context {
    return _context;
}

- (nullable id)valueForContextName:(NSString *)key {
    return [_context objectForKey:key];
}

- (void)setContextValue:(id)value forName:(NSString *)key {
    if (value) {
        [_context setObject:value forKey:key];
    } else {
        [_context removeObjectForKey:key];
    }
}

- (DIMFacebook *)facebook {
    id delegate = [self valueForContextName:@"facebook"];
    if (!delegate) {
        delegate = self.barrack;
        NSAssert([delegate isKindOfClass:[DIMFacebook class]], @"facebook error: %@", delegate);
    }
    return delegate;
}

- (nullable NSArray<DIMUser *> *)localUsers {
    return (NSArray<DIMUser *> *)[self valueForContextName:@"local_users"];
}

- (void)setLocalUsers:(NSArray<DIMUser *> *)localUsers {
    [self setContextValue:localUsers forName:@"local_users"];
}

- (nullable DIMUser *)currentUser {
    NSArray<DIMUser *> *users = self.localUsers;
    if ([users count] == 0) {
        return nil;
    }
    return [users firstObject];
}

- (void)setCurrentUser:(DIMUser *)currentUser {
    NSMutableArray *users = (NSMutableArray *)self.localUsers;
    if (!users) {
        users = [[NSMutableArray alloc] initWithCapacity:1];
        [self setLocalUsers:users];
    } else if (![users isKindOfClass:[NSMutableArray class]]) {
        users = [users mutableCopy];
        [self setLocalUsers:users];
    }
    if ([users count] == 0) {
        [users addObject:currentUser];
        return;
    }
    NSUInteger index = [users indexOfObject:currentUser];
    if (index != 0) {
        // set the current user in the front of local users list
        if (index != NSNotFound) {
            [users removeObject:currentUser];
        }
        [users insertObject:currentUser atIndex:0];
    }
}

- (nullable DIMUser *)selectUserWithID:(DIMID *)receiver {
    NSArray<DIMUser *> *users = self.localUsers;
    if ([users count] == 0) {
        NSAssert(false, @"local users should not be empty");
        return nil;
    } else if ([receiver isBroadcast]) {
        // broadcast message can decrypt by anyone, so just return current user
        return [users firstObject];
    }
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group message (recipient not designated)
        NSArray<DIMID *> *members = [self.facebook membersOfGroup:receiver];
        NSAssert([members count] > 0, @"group members not found: %@", receiver);
        for (DIMUser *item in users) {
            if ([members containsObject:item.ID]) {
                //self.currentUser = item;
                return item;
            }
        }
    } else {
        // 1. personal message
        // 2. split group message
        NSAssert(MKMNetwork_IsUser(receiver.type), @"error: %@", receiver);
        for (DIMUser *item in users) {
            if ([receiver isEqual:item.ID]) {
                //self.currentUser = item;
                return item;
            }
        }
    }
    NSAssert(false, @"receiver not in local users: %@, %@", receiver, users);
    return nil;
}

- (nullable DIMSecureMessage *)trimMessage:(DIMSecureMessage *)sMsg {
    DIMID *receiver = [self.facebook IDWithString:sMsg.envelope.receiver];
    DIMUser *user = [self selectUserWithID:receiver];
    if (!user) {
        // local users not matched
        return nil;
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // trim group message
        sMsg = [sMsg trimForMember:user.ID];
    }
    return sMsg;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.fileData != nil, @"content.fileData should not be empty");
        NSAssert(file.URL == nil, @"content.URL exists, already uploaded?");
        // encrypt and upload file data onto CDN and save the URL in message content
        NSData *CT = [key encrypt:file.fileData];
        NSURL *url = [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
        if (url) {
            // replace 'data' with 'URL'
            file.URL = url;
            file.fileData = nil;
        }
        //[iMsg setObject:file forKey:@"content"];
    }
    
    return [super message:iMsg encryptContent:content withKey:key];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                  encryptKey:(NSDictionary *)password
                 forReceiver:(NSString *)receiver {
    DIMID *to = DIMIDWithString(receiver);
    id<MKMEncryptKey> key = [self.facebook publicKeyForEncryption:to];
    if (!key) {
        DIMMeta *meta = [self.facebook metaForID:to];
        if (!meta) {
            // TODO: save this message in a queue waiting meta response
            return nil;
        }
    }
    return [super message:iMsg encryptKey:password forReceiver:receiver];
}

#pragma mark DKDSecureMessageDelegate

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                        decryptKey:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver {
    if (key) {
        DIMID *target = DIMIDWithString(sMsg.envelope.receiver);
        NSArray<id<MKMDecryptKey>> *keys;
        keys = [self.facebook privateKeysForDecryption:target];
        if ([keys count] == 0) {
            // FIXME: private key lost?
            @throw [NSException exceptionWithName:NSObjectNotAvailableException
                                           reason:@"Private Key Not Found"
                                         userInfo:sMsg];
        }
    }
    return [super message:sMsg decryptKey:key from:sender to:receiver];
}

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
                  decryptContent:(NSData *)data
                         withKey:(NSDictionary *)password {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    
    DIMContent *content = [super message:sMsg decryptContent:data withKey:key];
    if (!content) {
        return nil;
    }
    
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.URL != nil, @"content.URL should not be empty");
        NSAssert(file.fileData == nil, @"content.fileData already download");
        DIMInstantMessage *iMsg;
        iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                                 envelope:sMsg.envelope];
        // download from CDN
        NSData *fileData = [_delegate downloadEncryptedFileData:file.URL
                                                     forMessage:iMsg];
        if (fileData) {
            // decrypt file data
            file.fileData = [key decrypt:fileData];
            file.URL = nil;
        } else {
            // save the symmetric key for decrypte file data later
            file.password = key;
        }
        //content = file;
    }
    
    return content;
}

#pragma mark ConnectionDelegate

- (nullable NSData *)onReceivePackage:(NSData *)data {
    // TODO: CPU!
    return nil;
}

@end

@implementation DIMMessenger (Transform)

- (nullable DIMSecureMessage *)verifyMessage:(DIMReliableMessage *)rMsg {
    // Notice: check meta before calling me
    DIMID *sender = [_barrack IDWithString:rMsg.envelope.sender];
    DIMMeta *meta = MKMMetaFromDictionary(rMsg.meta);
    if (meta) {
        // [Meta Protocol]
        // save meta for sender
        if (![meta matchID:sender]) {
            NSAssert(false, @"meta not match: %@, %@", sender, meta);
            return nil;
        } else if (![self.facebook saveMeta:meta forID:sender]) {
            NSAssert(false, @"save meta error: %@, %@", sender, meta);
            return nil;
        }
    } else {
        meta = [_barrack metaForID:sender];
        if (!meta) {
            //[self queryMetaForID:sender];
            // TODO: save this message in a queue to wait meta response
            NSAssert(false, @"failed to get meta for sender: %@", sender);
            return nil;
        }
    }
    return [super verifyMessage:rMsg];
}

- (nullable DIMSecureMessage *)encryptMessage:(DIMInstantMessage *)iMsg {
    DIMSecureMessage *sMsg = [super encryptMessage:iMsg];
    NSString *group = iMsg.envelope.group;
    if (group) {
        // NOTICE: this help the receiver knows the group ID
        //         when the group message separated to multi-messages,
        //         if don't want the others know you are the group members,
        //         remove it.
        sMsg.envelope.group = group;
    }
    // NOTICE: copy content type to envelope
    //         this help the intermediate nodes to recognize message type
    sMsg.envelope.type = iMsg.envelope.type;
    return sMsg;
}

- (nullable DIMInstantMessage *)decryptMessage:(DIMSecureMessage *)sMsg {
    // 0. trim message
    sMsg = [self trimMessage:sMsg];
    if (!sMsg) {
        // not for you?
        return nil;
    }
    // 1. decrypt message
    DIMInstantMessage *iMsg = [super decryptMessage:sMsg];
    
    // 2. check top-secret message
    DIMContent *content = iMsg.content;
    NSAssert(content, @"content cannot be empty");
    if ([content isKindOfClass:[DIMForwardContent class]]) {
        // [Forward Protocol]
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *forward = (DIMForwardContent *)content;
        DIMReliableMessage *rMsg = forward.forwardMessage;
        NSAssert(rMsg, @"forward message error: %@", forward);
        sMsg = [self verifyMessage:rMsg];
        NSAssert(sMsg, @"signature error: %@", rMsg);
        DIMInstantMessage *secret = [self decryptMessage:sMsg];
        if (secret) {
            return secret;
        }
        // NOTICE: decrypt failed, not for you?
        //         check content type in subclass, if it's a 'forward' message,
        //         it means you are asked to re-pack and forward this message
    }
    
    return iMsg;
}

@end

@implementation DIMMessenger (Send)

- (BOOL)queryMetaForID:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)sendContent:(DIMContent *)content receiver:(DIMID *)receiver {
    return [self sendContent:content receiver:receiver callback:NULL dispersedly:YES];
}

- (BOOL)sendContent:(DIMContent *)content
           receiver:(DIMID *)receiver
           callback:(nullable DIMMessengerCallback)callback
        dispersedly:(BOOL)split {
    DIMUser *user = self.currentUser;
    NSAssert(user, @"current user not found");
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                               sender:user.ID
                                             receiver:receiver
                                                 time:nil];
    return [self sendInstantMessage:iMsg
                           callback:callback
                        dispersedly:split];
}

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMMessengerCallback)callback
               dispersedly:(BOOL)split {
    // Send message (secured + certified) to target station
    DIMSecureMessage *sMsg = [self encryptMessage:iMsg];
    DIMReliableMessage *rMsg = [self signMessage:sMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        iMsg.state = DIMMessageState_Error;
        iMsg.error = @"Encryption failed.";
        return NO;
    }
    
    DIMID *receiver = [_barrack IDWithString:iMsg.envelope.receiver];
    BOOL OK = YES;
    if (split && MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([receiver isEqual:iMsg.content.group], @"error: %@", iMsg);
        // split for each members
        NSArray<DIMID *> *members = [self.facebook membersOfGroup:receiver];
        NSAssert([members count] > 0, @"group members empty: %@", receiver);
        NSArray *messages = [rMsg splitForMembers:members];
        if ([members count] == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            OK = [self sendReliableMessage:rMsg callback:callback];
        } else {
            for (DIMReliableMessage *item in messages) {
                if (![self sendReliableMessage:item callback:callback]) {
                    OK = NO;
                }
            }
        }
    } else {
        OK = [self sendReliableMessage:rMsg callback:callback];
    }
    
    // sending status
    if (OK) {
        iMsg.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        iMsg.state = DIMMessageState_Waiting;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(nullable DIMMessengerCallback)callback {
    NSData *data = [self serializeMessage:rMsg];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

@end

@implementation DIMMessenger (Message)

- (nullable DIMContent *)forwardMessage:(DIMReliableMessage *)msg {
    DIMUser *user = self.currentUser;
    NSAssert(user, @"current user not found");
    DIMID *receiver = [self.facebook IDWithString:msg.envelope.receiver];
    // repack the top-secret message
    DIMContent *secret = [[DIMForwardContent alloc] initWithForwardMessage:msg];
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:secret
                                               sender:user.ID
                                             receiver:receiver
                                                 time:nil];
    // encrypt, sign & deliver it
    DIMSecureMessage *sMsg = [self encryptMessage:iMsg];
    DIMReliableMessage *rMsg = [self signMessage:sMsg];
    return [self deliverMessage:rMsg];
}

- (nullable DIMContent *)broadcastMessage:(DIMReliableMessage *)rMsg {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable DIMContent *)deliverMessage:(DIMReliableMessage *)rMsg {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)saveMessage:(DIMInstantMessage *)iMsg {
    NSAssert(false, @"override me!");
    return NO;
}

@end
