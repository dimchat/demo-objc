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

#import "DIMMessenger+Extension.h"

#import "SCMessagePacker.h"

static inline void fix_profile(id<DKDContent> content) {
    if ([content conformsToProtocol:@protocol(DKDDocumentCommand)]) {
        // compatible for document command
        id doc = [content objectForKey:@"document"];
        if (doc) {
            // (v2.0)
            //    "ID"       : "{ID}",
            //    "document" : {
            //        "ID"        : "{ID}",
            //        "data"      : "{JsON}",
            //        "signature" : "{BASE64}"
            //    }
            return;
        }
        id profile = [content objectForKey:@"profile"];
        if (profile) {
            [content removeObjectForKey:@"profile"];
            // 1.* => 2.0
            if ([profile isKindOfClass:[NSString class]]) {
                // compatible with v1.0
                //    "ID"        : "{ID}",
                //    "profile"   : "{JsON}",
                //    "signature" : "{BASE64}"
                doc = @{
                    @"ID": [content objectForKey:@"ID"],
                    @"data": profile,
                    @"signature": [content objectForKey:@"signature"]
                };
                [content setObject:doc forKey:@"document"];
            } else {
                // compatible with v1.1
                //    "ID"       : "{ID}",
                //    "profile"  : {
                //        "ID"        : "{ID}",
                //        "data"      : "{JsON}",
                //        "signature" : "{BASE64}"
                //    }
                [content setObject:profile forKey:@"document"];
            }
        }
    }
}

static inline void fix_visa(id<DKDReliableMessage> rMsg) {
    id profile = [rMsg objectForKey:@"profile"];
    if (profile) {
        [rMsg removeObjectForKey:@"profile"];
        // 1.* => 2.0
        id visa = [rMsg objectForKey:@"visa"];
        if (!visa) {
            [rMsg setObject:profile forKey:@"visa"];
        }
    }
}

@implementation SCMessagePacker

- (void)attachKeyDigest:(id<DKDReliableMessage>)rMsg {
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
    id<MKMID> sender = rMsg.envelope.sender;
    id<MKMID> group = rMsg.envelope.group;
    if (group) {
        key = [self.messenger cipherKeyFrom:sender to:group generate:NO];
    } else {
        id<MKMID> receiver = rMsg.envelope.receiver;
        key = [self.messenger cipherKeyFrom:sender to:receiver generate:NO];
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
    [self attachKeyDigest:rMsg];
    return [super serializeMessage:rMsg];
}

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    if ([data length] < 2) {
        return nil;
    }
    id<DKDReliableMessage> rMsg = [super deserializeMessage:data];
    fix_visa(rMsg);
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
            id<DKDCommand> command = [[DIMDocumentCommand alloc] initWithID:user.ID document:visa];
            [self.messenger sendContent:command sender:user.ID receiver:sMsg.sender priority:1];
        } else {
            // FIXME: message error?
            @throw exception;
        }
    } @finally {
        //
    }
    fix_profile(iMsg.content);
    return iMsg;
}

@end
