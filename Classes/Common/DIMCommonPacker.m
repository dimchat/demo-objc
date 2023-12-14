// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMCommonPacker.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/15.
//

#import "DIMCompatible.h"

#import "DIMCommonPacker.h"

@implementation DIMCommonPacker

- (id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    // 1. check contact info
    // 2. check group members info
    if ([self checkReceiverInInstantMessage:iMsg]) {
        // receiver is ready
    } else {
        NSLog(@"receiver not ready: %@", iMsg.receiver);
        return nil;
    }
    return [super encryptMessage:iMsg];
}

- (id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
    // 1. check sender's meta
    if ([self checkSenderInReliableMessage:rMsg]) {
        // sender is ready
    } else {
        NSLog(@"sender not ready: %@", rMsg.sender);
        return nil;
    }
    // 2. check receiver/group with local user
    if ([self checkReceiverInReliableMessage:rMsg]) {
        // receiver is ready
    } else {
        // receiver (group) not ready
        NSLog(@"receiver not ready: %@", rMsg.receiver);
        return nil;
    }
    return [super verifyMessage:rMsg];
}

- (id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg {
    if ([sMsg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        // already signed
        return (id<DKDReliableMessage>)sMsg;
    }
    return [super signMessage:sMsg];
}

- (id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    if ([data length] <= 4) {
        // message data error
        return nil;
    // } else if (data.first != '{'.codeUnitAt(0) || data.last != '}'.codeUnitAt(0)) {
    //   // only support JsON format now
    //   return null;
    }
    id<DKDReliableMessage> rMsg = [super deserializeMessage:data];
    if (rMsg) {
        [DIMCompatible fixMetaAttachment:rMsg];
    }
    return rMsg;
}

- (NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    [DIMCompatible fixMetaAttachment:rMsg];
    return [super serializeMessage:rMsg];
}

@end

@implementation DIMCommonPacker (Suspend)

- (void)suspendReliableMessage:(id<DKDReliableMessage>)rMsg
                         error:(NSDictionary *)info {
    NSLog(@"TODO: suspendReliableMessage");
}

- (void)suspendInstantMessage:(id<DKDInstantMessage>)iMsg
                        error:(NSDictionary *)info {
    NSLog(@"TODO: suspendInstantMessage");
}

@end

@implementation DIMCommonPacker (Checking)

- (nullable id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    NSAssert([user isUser], @"user ID error: %@", user);
    return [self.facebook publicKeyForEncryption:user];
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    return [self.facebook membersOfGroup:group];
}

- (BOOL)checkSenderInReliableMessage:(id<DKDReliableMessage>)rMsg {
    id<MKMID> sender = [rMsg sender];
    NSAssert([sender isUser], @"sender error: %@", sender);
    // check sender's meta & document
    id<MKMVisa> visa = DIMMessageGetVisa(rMsg);
    if (visa) {
        // first handshake?
        NSAssert([visa.ID isEqual:sender], @"visa ID not match: %@", sender);
        return [visa.ID isEqual:sender];
    } else if ([self visaKeyForID:sender]) {
        // sender is OK
        return YES;
    }
    // sender not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"verify key not found",
        @"user": sender.string,
    };
    [self suspendReliableMessage:rMsg error:error];  // rMsg.put("error", error);
    return NO;
}

- (BOOL)checkReceiverInReliableMessage:(id<DKDReliableMessage>)sMsg {
    id<MKMID> receiver = [sMsg receiver];
    // check group
    id<MKMID> group = MKMIDParse([sMsg objectForKey:@"group"]);
    if (!group && [receiver isGroup]) {
        /// Transform:
        ///     (B) => (J)
        ///     (D) => (G)
        group = receiver;
    }
    if (!group || [group isBroadcast]) {
        /// A, C - personal message (or hidden group message)
        //      the packer will call the facebook to select a user from local
        //      for this receiver, if no user matched (private key not found),
        //      this message will be ignored;
        /// E, F, G - broadcast group message
        //      broadcast message is not encrypted, so it can be read by anyone.
        return YES;
    }
    /// H, J, K - group message
    //      check for received group message
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if ([members count] > 0) {
        // group is ready
        return YES;
    }
    // group not ready, suspend message for waiting members
    NSDictionary *error = @{
        @"message": @"group not ready",
        @"group": group.string,
    };
    [self suspendReliableMessage:sMsg error:error];  // rMsg.put("error", error);
    return NO;
}

- (BOOL)checkReceiverInInstantMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = [iMsg receiver];
    if ([receiver isBroadcast]) {
        // broadcast message
        return YES;
    } else if ([receiver isGroup]) {
        // NOTICE: station will never send group message, so
        //         we don't need to check group info here; and
        //         if a client wants to send group message,
        //         that should be sent to a group bot first,
        //         and the bot will split it for all members.
        return NO;
    } else if ([self visaKeyForID:receiver]) {
        // receiver is OK
        return YES;
    }
    // receiver not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"encrypt key not found",
        @"user": receiver.string,
    };
    [self suspendInstantMessage:iMsg error:error];  // iMsg.put("error", error);
    return NO;
}

@end
