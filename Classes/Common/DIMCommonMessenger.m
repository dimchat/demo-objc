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
//  DIMClient
//
//  Created by Albert Moky on 2023/3/5.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMCompatible.h"

#import "DIMCommonMessenger.h"

@interface DIMCommonMessenger () {
    
    id<DIMPacker> _packer;
    id<DIMProcessor> _processor;
    
    id<DIMCipherKeyDelegate> _database;
}

@property(nonatomic, strong) DIMCommonFacebook *facebook;
@property(nonatomic, strong) id<DIMSession> session;

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
                        database:(id<DIMCipherKeyDelegate>)db {
    if (self = [super init]) {
        _facebook = barrack;
        _session = session;
        _database = db;
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

#pragma mark DKDInstantMessageDelegate

// Override
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    @try {
        return [super message:iMsg encryptKey:data forReceiver:receiver];
    } @catch (NSException *exception) {
        // FIXME:
        NSLog(@"failed to encrypt key for receiver: %@, error: %@", receiver, exception);
    } @finally {
        //
    }
}

// Override
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    // TODO: reuse message key
    
    // 0. check message key
    id reused = [password objectForKey:@"reused"];
    id digest = [password objectForKey:@"digest"];
    if (!reused && !digest) {
        // flags not exist, serialize it directly
        return [super message:iMsg serializeKey:password];
    }
    // 1. remove before serializing key
    [password removeObjectForKey:@"reused"];
    [password removeObjectForKey:@"digest"];
    // 2. serialize key without flags
    NSData *data = [super message:iMsg serializeKey:password];
    // 3. put them back after serialized
    if (MKMConverterGetBool(reused, NO)) {
        [password setObject:@(YES) forKey:@"reused"];
    }
    if (digest) {
        [password setObject:digest forKey:@"digest"];
    }
    // OK
    return data;
}

- (NSData *)message:(id<DKDInstantMessage>)iMsg
   serializeContent:(id<DKDContent>)content
            withKey:(id<MKMSymmetricKey>)password {
    if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        id<DKDCommand> command = (id<DKDCommand>)content;
        content = [DIMCompatible fixCommand:command];
    }
    return [super message:iMsg serializeContent:content withKey:password];
}

- (id<DKDContent>)message:(id<DKDSecureMessage>)sMsg
       deserializeContent:(NSData *)data
                  withKey:(id<MKMSymmetricKey>)password {
    id<DKDContent> content = [super message:sMsg
                         deserializeContent:data
                                    withKey:password];
    if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        id<DKDCommand> command = (id<DKDCommand>)content;
        content = [DIMCompatible fixCommand:command];
    }
    return content;
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
    // 0. check cycled message
    if ([iMsg.sender isEqual:iMsg.receiver]) {
        NSLog(@"drop cycled message: %@, %@ => %@, %@", iMsg.content,
              iMsg.sender, iMsg.receiver, iMsg.group);
        return nil;
    } else {
        NSLog(@"send instant message (type=%u): %@ => %@, %@", iMsg.content.type,
              iMsg.sender, iMsg.receiver, iMsg.group);
    }
    // 1. encrypt message
    id<DKDSecureMessage> sMsg = [self encryptMessage:iMsg];
    if (!sMsg) {
        // public key not found?
        return nil;
    }
    // 2. sign message
    id<DKDReliableMessage> rMsg = [self signMessage:sMsg];
    if (!rMsg) {
        // TODO: set msg.state = error
        NSAssert(false, @"failed to sign message: %@", sMsg);
        return nil;
    }
    // 3. send message
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
    // 0. check cycled message
    if ([rMsg.sender isEqual:rMsg.receiver]) {
        NSLog(@"drop cycled message: %@ => %@, %@",
              rMsg.sender, rMsg.receiver, rMsg.group);
        return nil;
    }
    // 1. serialize message
    NSData *data = [self serializeMessage:rMsg];
    NSAssert(data, @"failed to serialize message: %@", rMsg);
    // 2. call gate keeper to send the message data package
    //    put message package into the waiting queue of current session
    return [_session queueMessage:rMsg package:data priority:prior];
}

@end
