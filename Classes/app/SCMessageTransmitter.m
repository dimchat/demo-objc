// license: https://mit-license.org
//
//  SeChat : Secure/secret Chat Application
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  SCMessageTransmitter.m
//  DIMClient
//
//  Created by Albert Moky on 2021/10/14.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import "DKDInstantMessage+Extension.h"
#import "DIMMessenger+Extension.h"

#import "SCMessageTransmitter.h"

@interface SCMessageTransmitter ()

@property (weak, nonatomic) DIMMessenger *messenger;
@property (weak, nonatomic) DIMFacebook *facebook;

@end

@implementation SCMessageTransmitter

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    DIMFacebook *barrack = nil;
    DIMMessenger *transceiver = nil;
    return [self initWithFacebook:barrack messenger:transceiver];
}

/* designated initializer */
- (instancetype)initWithFacebook:(DIMFacebook *)barrack
                       messenger:(DIMMessenger *)transceiver {
    if (self = [super init]) {
        self.facebook = barrack;
        self.messenger = transceiver;
    }
    return self;
}

- (BOOL)sendContent:(id<DKDContent>)content
             sender:(nullable id<MKMID>)from
           receiver:(id<MKMID>)to
           priority:(NSInteger)prior {
    // Application Layer should make sure user is already login before it send message to server.
    // Application layer should put message into queue so that it will send automatically after user login
    if (!from) {
        id<DIMUser> user = [self.facebook currentUser];
        NSAssert(user, @"current user not set");
        from = user.ID;
    }
    id<DKDEnvelope> env = DKDEnvelopeCreate(from, to, nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, content);
    return [self.messenger sendInstantMessage:iMsg priority:prior];
}

- (BOOL)sendInstantMessage:(id<DKDInstantMessage>)iMsg priority:(NSInteger)prior {
    // Send message (secured + certified) to target station
    id<DKDSecureMessage> sMsg = [self.messenger encryptMessage:iMsg];
    if (!sMsg) {
        // FIXME: public key not found?
        //NSAssert(false, @"failed to encrypt message: %@", iMsg);
        return NO;
    }
    id<DKDReliableMessage> rMsg = [self.messenger signMessage:sMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to sign message: %@", sMsg);
        DKDContent *content = iMsg.content;
        content.state = DIMMessageState_Error;
        content.error = @"Encryption failed.";
        return NO;
    }
    
    BOOL OK = [self sendReliableMessage:rMsg priority:prior];
    // sending status
    if (OK) {
        DKDContent *content = iMsg.content;
        content.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        DKDContent *content = iMsg.content;
        content.state = DIMMessageState_Waiting;
    }
    
    if (![self.messenger saveMessage:iMsg]) {
        return NO;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg priority:(NSInteger)prior {
    NSData *data = [self.messenger serializeMessage:rMsg];
    return [self.messenger sendPackageData:data priority:prior];
}

@end
