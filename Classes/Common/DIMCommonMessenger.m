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
//  DIMCommonMessenger.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/5.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMCommonMessenger.h"

@interface DIMCommonMessenger () {
    
    id<DIMPacker> _packer;
    id<DIMProcessor> _processor;
}

@property(nonatomic, strong) DIMCommonFacebook *facebook;
@property(nonatomic, strong) id<DIMSession> session;
@property(nonatomic, strong) id<DIMMessageDBI> database;

@end

@implementation DIMCommonMessenger

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    DIMCommonFacebook *barrack = nil;
    id<DIMSession> session = nil;
    id<DIMMessageDBI> db = nil;
    return [self initWithFacebook:barrack session:session database:db];
}

/* designated initializer */
- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack
                         session:(id<DIMSession>)session
                        database:(id<DIMMessageDBI>)db {
    if (self = [super init]) {
        self.facebook = barrack;
        self.session = session;
        self.database = db;
    }
    return self;
}

// Override
- (id<MKMEntityDelegate>)barrack {
    return _facebook;
}

// Override
- (id<DIMCipherKeyDelegate>)keyCache {
    return _database;
}

// Override
- (id<DIMPacker>)packer {
    return _packer;
}

- (void)setPacker:(id<DIMPacker>)packer {
    _packer = packer;
}

// Override
- (id<DIMProcessor>)processor {
    return _processor;
}

- (void)setProcessor:(id<DIMProcessor>)processor {
    _processor = processor;
}

#pragma mark DIMPacker

// Override
- (id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    if (![self checkReceiverForInstantMessage:iMsg]) {
        // receiver not ready
        NSLog(@"receiver not ready: %@", [iMsg receiver]);
        return nil;
    }
    return [super encryptMessage:iMsg];
}

// Override
- (id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
    if (![self checkReceiverForSecureMessage:rMsg]) {
        // receiver (group) not ready
        NSLog(@"receiver (group) not ready: %@", [rMsg receiver]);
        return nil;
    }
    if (![self checkSenderForReliableMessage:rMsg]) {
        // sender not ready
        NSLog(@"sender not ready: %@", [rMsg sender]);
        return nil;
    }
    return [super verifyMessage:rMsg];
}

#pragma mark DIMTransmitter

- (DIMTransmitterResults *)sendContent:(id<DKDContent>)content
                                sender:(nullable id<MKMID>)from
                              receiver:(id<MKMID>)to
                              priority:(NSInteger)prior {
    if (!from) {
        id<MKMUser> current = [_facebook currentUser];
        NSAssert(current, @"current user not set");
        from = current.ID;
    }
    id<DKDEnvelope> env = DKDEnvelopeCreate(from, to, nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, content);
    id<DKDReliableMessage> rMsg = [self sendInstantMessage:iMsg priority:prior];
    return [[DIMTransmitterResults alloc] initWithFirst:iMsg second:rMsg];
}

- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior {
    // send message (secured + certified) to target station
    id<DKDSecureMessage> sMsg = [self encryptMessage:iMsg];
    if (!sMsg) {
        // public key not found?
        return nil;
    }
    id<DKDReliableMessage> rMsg = [self signMessage:sMsg];
    if (!rMsg) {
        // TODO: set msg.state = error
        NSAssert(false, @"failed to sign message: %@", sMsg);
        return nil;
    }
    BOOL ok = [self sendReliableMessage:rMsg priority:prior];
    if (ok) {
        return rMsg;
    } else {
        // failed
        return nil;
    }
}

- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg
                   priority:(NSInteger)prior {
    // 1. serialize message
    NSData *data = [self serializeMessage:rMsg];
    NSAssert(data, @"failed to serialize message: %@", rMsg);
    // 2. call gate keeper to send the message data package
    //    put message package into the waiting queue of current session
    return [_session queueMessage:rMsg package:data priority:prior];
}

@end

@implementation DIMCommonMessenger (Querying)

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)queryDocumentForID:(id<MKMID>)ID {
    NSAssert(false, @"override me!");
    return NO;
}

- (BOOL)queryMembersForID:(id<MKMID>)group {
    NSAssert(false, @"override me!");
    return NO;
}

@end

@implementation DIMCommonMessenger (Waiting)

- (void)suspendReliableMessage:(id<DKDReliableMessage>)rMsg
                     errorInfo:(NSDictionary<NSString *, id> *)info {
    NSAssert(false, @"override me!");
}

- (void)suspendInstantMessage:(id<DKDInstantMessage>)iMsg
                    errorInfo:(NSDictionary<NSString *, id> *)info {
    NSAssert(false, @"override me!");
}

@end

@implementation DIMCommonMessenger (Checking)

- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    id<MKMEncryptKey> visaKey = [_facebook publicKeyForEncryption:user];
    if (visaKey) {
        // user is ready
        return visaKey;
    }
    // user not ready, try to query document for it
    if ([self queryDocumentForID:user]) {
        NSLog(@"querying document for user: %@", user);
    }
    return nil;
}

- (NSArray<id<MKMID>> *)membersForID:(id<MKMID>)group {
    id<MKMMeta> meta = [_facebook metaForID:group];
    if (!meta/* || !meta.key*/) {
        // group not ready, try to query meta for it
        if ([self queryMetaForID:group]) {
            NSLog(@"querying meta for group: %@", group);
        }
        return nil;
    }
    id<MKMGroup> grp = [_facebook groupWithID:group];
    NSArray<id<MKMID>> *members = [grp members];
    if ([members count] == 0) {
        // group not ready, try to query members for it
        if ([self queryMembersForID:group]) {
            NSLog(@"querying members for group: %@", group);
        }
        return nil;
    }
    // group is ready
    return members;
}

- (BOOL)checkSenderForReliableMessage:(id<DKDReliableMessage>)rMsg {
    id<MKMID> sender = [rMsg sender];
    NSAssert(MKMIDIsUser(sender), @"sender error: %@", sender);
    // check sender's meta & document
    id<MKMVisa> visa = [rMsg visa];
    if (visa) {
        // first handshake?
        NSAssert([visa.ID isEqual:sender], @"visa ID not match: %@", sender);
        //NSAssert(MKMMetaMatchID(sender, rMsg.meta), @"meta error: %@", rMsg);
        return YES;
    } else if ([self visaKeyForID:sender]) {
        // sender is OK
        return YES;
    }
    // sender not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"verify key not found",
        @"user": [sender string],
    };
    [self suspendReliableMessage:rMsg errorInfo:error];
    //[rMsg setObject:error forKey:@"error"];
    return NO;
}

- (BOOL)checkReceiverForSecureMessage:(id<DKDSecureMessage>)sMsg {
    id<MKMID> receiver = [sMsg receiver];
    if (MKMIDIsBroadcast(receiver)) {
        // broadcast message
        return YES;
    } else if (MKMIDIsGroup(receiver)) {
        // check for received group message
        NSArray<id<MKMID>> *members = [self membersForID:receiver];
        return members != nil;
    }
    // the facebook will select a user from local users to match this receiver,
    // if no user matched (private key not found), this message will be ignored.
    return YES;
}

- (BOOL)checkReceiverForInstantMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = [iMsg receiver];
    if (MKMIDIsBroadcast(receiver)) {
        // broadcast message
        return YES;
    } else if (MKMIDIsGroup(receiver)) {
        // NOTICE: station will never send group message, so
        //         we don't need to check group info here; and
        //         if a client wants to send group message,
        //         that should be sent to a group bot first,
        //         and the bot will separate it for all members.
        return NO;
    } else if ([self visaKeyForID:receiver]) {
        // receiver is OK
        return YES;
    }
    // receiver not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"encrypt key not found",
        @"user": [receiver string],
    };
    [self suspendInstantMessage:iMsg errorInfo:error];
    //[iMsg setObject:error forKey:@"error"];
    return NO;
}

#pragma mark DKDInstantMessageDelegate

/*/
// Override
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    // try to reuse message key
    id reused = [password objectForKey:@"reused"];
    if (reused) {
        id<MKMID> receiver = [iMsg receiver];
        if (MKMIDIsGroup(receiver)) {
            // reuse key for grouped message
            return nil;
        }
        // remove before serialize key
        [password removeObjectForKey:@"reused"];
    }
    NSData *data = [super message:iMsg serializeKey:password];
    if (reused) {
        // put it back
        [password setObject:reused forKey:@"reused"];
    }
    return data;
}
/*/

@end
