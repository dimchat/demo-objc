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
//  SCMessagePacker.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/19.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DKDInstantMessage+Extension.h"
#import "DIMMessenger+Extension.h"

#import "SCMessagePacker.h"

@implementation SCMessagePacker

static inline NSString *key_digest(id<MKMSymmetricKey> key) {
    NSData *data = key.data;
    if ([data length] < 6) {
        // plain key?
        return nil;
    }
    // get digest for the last 6 bytes of key.data
    NSRange range = NSMakeRange([data length] - 6, 6);
    NSData *part = [data subdataWithRange:range];
    NSData *digest = MKMSHA256Digest(part);
    NSString *base64 = MKMBase64Encode(digest);
    NSCharacterSet *cset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    base64 = [base64 stringByTrimmingCharactersInSet:cset];
    NSUInteger pos = base64.length - 8;
    return [base64 substringFromIndex:pos];
}

- (void)attachKeyDigest:(id<DKDReliableMessage>)rMsg {
    if (rMsg.delegate == nil) {
        rMsg.delegate = self.messenger;
    }
    if ([rMsg encryptedKey]) {
        // 'key' exists
        return;
    }
    NSDictionary *keys = [rMsg encryptedKeys];
    if (!keys) {
        keys = @{};
    }
    if ([keys objectForKey:@"digest"]) {
        // key digest already exists
        return;
    }
    // get key with direction
    id<MKMSymmetricKey> key;
    id<MKMID> sender = rMsg.envelope.sender;
    id<MKMID> group = rMsg.envelope.group;
    if (group) {
        key = [self.messenger cipherKeyFrom:sender to:group generate:NO];
    } else {
        id<MKMID> receiver = rMsg.envelope.receiver;
        key = [self.messenger cipherKeyFrom:sender to:receiver generate:NO];
    }
    NSString *digest = key_digest(key);
    if (!digest) {
        // broadcast message has no key
        return;
    }
    NSMutableDictionary *mDict;
    if ([keys isKindOfClass:[NSMutableDictionary class]]) {
        mDict = (NSMutableDictionary *)keys;
    } else {
        mDict = [[NSMutableDictionary alloc] initWithDictionary:keys];
    }
    [mDict setObject:digest forKey:@"digest"];
    [rMsg setObject:mDict forKey:@"keys"];
}

#pragma mark Serialization

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    [DIMInstantMessage fixMetaAttachment:rMsg];
    [self attachKeyDigest:rMsg];
    return [super serializeMessage:rMsg];
}

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    if ([data length] < 2) {
        return nil;
    }
    id<DKDReliableMessage> rMsg = [super deserializeMessage:data];
    if (rMsg) {
        [DIMInstantMessage fixMetaAttachment:rMsg];
    }
    return rMsg;
}

- (id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
    id<MKMID> sender = rMsg.sender;
    // [Meta Protocol]
    id<MKMMeta> meta = rMsg.meta;
    if (!meta) {
        // get from local storage
        meta = [self.facebook metaForID:sender];
    } else if (!MKMMetaMatchID(sender, meta)) {
        meta = nil;
    }
    if (!meta) {
        // NOTICE: the application will query meta automatically
        // save this message in a queue waiting sender's meta response
        [self.messenger suspendMessage:rMsg];
        return nil;
    }
    
    // make sure meta exists before verifying message
    return [super verifyMessage:rMsg];
}

#pragma mark Reuse message key

- (BOOL)isWaiting:(id<MKMID>)ID {
    if (MKMIDIsGroup(ID)) {
        // checking group meta
        return [self.facebook metaForID:ID] == nil;
    } else {
        // checking visa key
        return [self.facebook publicKeyForEncryption:ID] == nil;
    }
}

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = iMsg.receiver;
    id<MKMID> group = iMsg.group;
    if (!MKMIDIsBroadcast(receiver) && !MKMIDIsBroadcast(group)) {
        // this message is not a broadcast message
        if ([self isWaiting:receiver] || (group && [self isWaiting:group])) {
            // NOTICE: the application will query visa automatically
            // save this message in a queue waiting sender's visa response
            [self.messenger suspendMessage:iMsg];
            return nil;
        }
    }
    
    // make sure visa.key exists before encrypting message
    id<DKDSecureMessage> sMsg = [super encryptMessage:iMsg];
    
    if (MKMIDIsGroup(receiver)) {
        // reuse group message keys
        id<MKMID> sender = iMsg.sender;
        id<MKMSymmetricKey> key = [self.messenger cipherKeyFrom:sender to:receiver generate:NO];
        [key setObject:@(YES) forKey:@"reused"];
    }
    // TODO: reuse personal message key?
    
    return sMsg;
}

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg {
    id<DKDInstantMessage> iMsg = nil;
    @try {
        iMsg = [super decryptMessage:sMsg];
    } @catch (NSException *exception) {
        // check exception thrown by DKD: chat.dim.dkd.EncryptedMessage.decrypt()
        if ([exception.reason isEqualToString:@"failed to decrypt key in msg"]) {
            // visa.key not updated?
            id<DIMUser> user = [self.facebook currentUser];
            id<MKMVisa> visa = user.visa;
            NSAssert([visa isValid], @"user visa not found: %@", user);
            id<DKDContent> content = [[DIMDocumentCommand alloc] initWithID:user.ID document:visa];
            [self.messenger sendContent:content sender:user.ID receiver:sMsg.sender priority:1];
        } else {
            // FIXME: message error?
            @throw exception;
        }
    } @finally {
        //
    }
    return iMsg;
}

@end
