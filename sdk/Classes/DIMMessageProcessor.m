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
//  DIMMessageProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMFacebook.h"
#import "DIMContentProcessor.h"

#import "DIMMessageProcessor.h"

@interface DIMMessageProcessor () {
    
    DIMContentProcessor *_cpu;
    
    __weak DIMMessenger *_messenger;
    __weak DIMFacebook *_facebook;
}

@end

@implementation DIMMessageProcessor

- (instancetype)initWithMessenger:(DIMMessenger *)messenger {
    if (self = [super init]) {
        _cpu = [[DIMContentProcessor alloc] initWithMessenger:messenger];
        _messenger = messenger;
        _facebook = messenger.facebook;
    }
    return self;
}

- (DIMFacebook *)facebook {
    return [_messenger facebook];
}

- (BOOL)_isEmptyGroup:(DIMID *)group {
    NSArray *members = [_facebook membersOfGroup:group];
    if ([members count] == 0) {
        return YES;
    }
    DIMID *owner = [_facebook ownerOfGroup:group];
    return !owner;
}

// check whether need to update group
- (BOOL)_checkGroup:(DIMContent *)content sender:(DIMID *)sender {
    // check if it's a group message,
    // and whether the group members info needs update
    DIMID *group = [_facebook IDWithString:content.group];
    if (!group || [group isBroadcast]) {
        // 1. personal message
        // 2. broadcast message
        return NO;
    }
    // chek meta for new group ID
    DIMMeta *meta = [_facebook metaForID:group];
    if (!meta) {
        // NOTICE: if meta for group not found,
        //         facebook should query it from DIM network automatically
        // TODO: insert the message to a temporary queue to wait meta
        NSAssert(false, @"group meta not found: %@", group);
        return YES;
    }
    BOOL needsUpdate = [self _isEmptyGroup:group];
    if ([content isKindOfClass:[DIMInviteCommand class]]) {
        // FIXME: can we trust this stranger?
        //        may be we should keep this members list temporary,
        //        and send 'query' to the owner immediately.
        // TODO: check whether the members list is a full list,
        //       it should contain the group owner(owner)
        needsUpdate = NO;
    }
    if (needsUpdate) {
        DIMCommand *cmd = [[DIMQueryGroupCommand alloc] initWithGroup:group];
        return [_messenger sendContent:cmd receiver:sender];
    }
    return NO;
}

- (nullable DIMContent *)processMessage:(DIMReliableMessage *)rMsg {
    // 0. verify
    DIMSecureMessage *sMsg = [_messenger verifyMessage:rMsg];
    if (!sMsg) {
        NSAssert(false, @"failed to verify message: %@", rMsg);
        return nil;
    }
    
    // 1. check broadcast
    DIMID *receiver = [_facebook IDWithString:rMsg.envelope.receiver];
    if (MKMNetwork_IsGroup(receiver.type) && [receiver isBroadcast]) {
        // if it's a grouped broadcast ID, then
        // split and deliver to everyone
        return [_messenger broadcastMessage:rMsg];
    }
    
    // 2. try to decrypt
    DIMInstantMessage *iMsg = [_messenger decryptMessage:sMsg];
    if (!iMsg) {
        // cannot decrypt this message, not for you?
        // deliver to the receiver
        return [_messenger deliverMessage:rMsg];
    }
    
    // 3. check top-secret message
    DIMContent *content = iMsg.content;
    if ([content isKindOfClass:[DIMForwardContent class]]) {
        // it's asking you to forward it
        DIMForwardContent *forward = (DIMForwardContent *)content;
        return [_messenger forwardMessage:forward.forwardMessage];
    }
    
    // 4. check group
    DIMID *sender = [_facebook IDWithString:rMsg.envelope.sender];
    if ([self _checkGroup:content sender:sender]) {
        // sending query group command
    }
    
    // 5. process
    DIMContent *res = [_cpu processContent:content sender:sender message:iMsg];
    if ([_messenger saveMessage:iMsg]) {
        return res;
    }
    // error
    return nil;
}

#pragma mark ConnectionDelegate

- (nullable NSData *)onReceivePackage:(NSData *)data {
    DIMReliableMessage *rMsg = [_messenger deserializeMessage:data];
    DIMContent *res = [self processMessage:rMsg];
    if (!res) {
        // nothing to response
        return nil;
    }
    DIMUser *user = [_messenger currentUser];
    NSAssert(user, @"failed to get current user");
    DIMID *receiver = [_facebook IDWithString:rMsg.envelope.sender];
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:res
                                               sender:user.ID
                                             receiver:receiver
                                                 time:nil];
    DIMSecureMessage *sMsg = [_messenger encryptMessage:iMsg];
    NSAssert(sMsg, @"failed to encrypt message: %@", iMsg);
    DIMReliableMessage *nMsg = [_messenger signMessage:sMsg];
    NSAssert(nMsg, @"failed to sign message: %@", sMsg);
    return [_messenger serializeMessage:nMsg];
}

@end
