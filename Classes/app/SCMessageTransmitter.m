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

#import "DIMMessenger+Extension.h"

#import "SCMessageTransmitter.h"

@implementation SCMessageTransmitter

- (BOOL)sendInstantMessage:(id<DKDInstantMessage>)iMsg callback:(nullable DIMMessengerCallback)fn priority:(NSInteger)prior {
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
    
    BOOL OK = [self sendReliableMessage:rMsg callback:fn priority:prior];
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

- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg callback:(nullable DIMMessengerCallback)fn priority:(NSInteger)prior {
    DIMMessengerCompletionHandler handler;
    if (fn) {
        handler = ^(NSError * _Nullable error) {
            fn(rMsg, error);
        };
    }
    NSData *data = [self.messenger serializeMessage:rMsg];
    return [self.messenger sendPackageData:data completionHandler:handler priority:prior];
}

@end
