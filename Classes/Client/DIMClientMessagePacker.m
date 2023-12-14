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
//  DIMClientMessagePacker.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMClientMessagePacker.h"

//static inline NSString *trim(NSString *string) {
//    NSCharacterSet *set = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
//    return [string stringByTrimmingCharactersInSet:set];
//}
//
//// get partially key data for digest
//static inline NSString *key_digest(id<MKMSymmetricKey> key) {
//    NSData *data = [key data];
//    NSUInteger len = [data length];
//    if (len < 6) {
//        // plain key?
//        return nil;
//    }
//    // get digest for the last 6 bytes of key.data
//    NSData *tail = [data subdataWithRange:NSMakeRange(len - 6, 6)];
//    NSData *digest = MKMSHA256Digest(tail);
//    NSString *base64 = MKMBase58Encode(digest);
//    base64 = trim(base64);
//    return [base64 substringFromIndex:(base64.length - 8)];
//}

@implementation DIMClientMessagePacker

//- (void)attachKeyDigestForReliableMessage:(id<DKDReliableMessage>)rMsg {
//    DIMMessenger *messenger = [self messenger];
//    // check message delegate
//    if ([rMsg delegate] == nil) {
//        [rMsg setDelegate:messenger];
//    }
//    // check msg.key
//    if ([rMsg objectForKey:@"key"]) {
//        // key exists
//        return;
//    }
//    // check msg.keys
//    id encryptedKeys = [rMsg encryptedKeys];
//    NSMutableDictionary<NSString *, NSString *> *keys;
//    if (!encryptedKeys) {
//        keys = [[NSMutableDictionary alloc] init];
//    } else if ([encryptedKeys objectForKey:@"digest"]) {
//        // key digest already exists
//        return;
//    } else if ([encryptedKeys isKindOfClass:[NSMutableDictionary class]]) {
//        keys = encryptedKeys;
//    } else {
//        keys = [encryptedKeys mutableCopy];
//    }
//
//    // get key with direction
//    id<MKMSymmetricKey> key;
//    id<MKMID> sender = [rMsg sender];
//    id<MKMID> group = [rMsg group];
//    if (group) {
//        key = [messenger cipherKeyFrom:sender to:group generate:NO];
//    } else {
//        id<MKMID> receiver = [rMsg receiver];
//        key = [messenger cipherKeyFrom:sender to:receiver generate:NO];
//    }
//    NSString *digest = key_digest(key);
//    if (digest) {
//        [keys setObject:digest forKey:@"digest"];
//        [rMsg setObject:keys forKey:@"keys"];
//    }
//}
//
//// Override
//- (NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
//    [self attachKeyDigestForReliableMessage:rMsg];
//    return [super serializeMessage:rMsg];
//}

/*/
// Override
- (id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    // make sure visa.key exists before encrypting message
    id<DKDSecureMessage> sMsg = [super encryptMessage:iMsg];
    id<MKMID> receiver = [iMsg receiver];
    if (MKMIDIsGroup(receiver)) {
        // reuse group message
        DIMMessenger *messenger = [self messenger];
        id<MKMID> sender = [iMsg sender];
        id<MKMSymmetricKey> key = [messenger cipherKeyFrom:sender
                                                        to:receiver
                                                  generate:NO];
        [key setObject:@(YES) forKey:@"reused"];
    }
    // TODO: reuse personal message key?
    return sMsg;
}
/*/

//// Override
//- (id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg {
//    @try {
//        return [super decryptMessage:sMsg];
//    } @catch (NSException *exception) {
//        // TODO: check exception thrown by DKD: chat.dim.dkd.EncryptedMessage.decrypt()
//    }
//}

- (BOOL)checkReceiverInInstantMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = [iMsg receiver];
    if ([receiver isBroadcast]) {
        // broadcast
        return YES;
    } else if ([receiver isUser]) {
        // check user's meta & document
        return [super checkReceiverInInstantMessage:iMsg];
    }
    //
    //  check group's meta & members
    //
    NSArray<id<MKMID>> *members = [self membersOfGroup:receiver];
    if ([members count] == 0) {
        // group not ready, suspend message for waiting meta/members
        NSDictionary *error = @{
            @"message": @"group members not found",
            @"group": receiver.string,
        };
        [self suspendInstantMessage:iMsg error:error];  // iMsg.put("error", error);
        return NO;
    }
    //
    //  check group members' visa key
    //
    NSMutableArray<id<MKMID>> *waiting = [[NSMutableArray alloc] init];
    for (id<MKMID> item in members) {
        if ([self visaKeyForID:item]) {
            // member is ready
        } else {
            [waiting addObject:item];
        }
    }
    if ([waiting count] == 0) {
        // all member's visa keys exist
        return YES;
    }
    // members not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"members not ready",
        @"group": receiver.string,
        @"members": MKMIDRevert(waiting),
    };
    [self suspendInstantMessage:iMsg error:error];  // iMsg.put("error", error);
    // perhaps some members have already disappeared,
    // although the packer will query document when the member's visa key is not found,
    // but the station will never respond with the right document,
    // so we must return true here to let the messaging continue;
    // when the member's visa is responded, we should send the suspended message again.
    return [waiting count] < [members count];
}

@end
