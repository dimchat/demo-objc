// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMReceiptCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

@implementation DIMReceiptCommand

- (instancetype)initWithMessage:(NSString *)message envelope:(id<DKDEnvelope>)env sn:(NSUInteger)num {
    if (self = [self initWithCommandName:DIMCommand_Receipt]) {
        // message
        if (message) {
            [self setObject:message forKey:@"message"];
        }
        // sn of the message responding to
        if (num > 0) {
            [self setObject:@(num) forKey:@"sn"];
        }
        // envelope of the message responding to
        if (env) {
            [self setEnvelope:env];
        }
    }
    return self;
}
- (instancetype)initWithMessage:(NSString *)message {
    id<DKDEnvelope> env = nil;
    return [self initWithMessage:message envelope:env sn:0];
}

- (NSString *)message {
    return [self objectForKey:@"message"];
}

- (nullable id<DKDEnvelope>)envelope {
    NSString *sender = [self objectForKey:@"sender"];
    NSString *receiver = [self objectForKey:@"receiver"];
    if (sender && receiver) {
        return DKDEnvelopeFromDictionary(self.dictionary);
    } else {
        return nil;
    }
}

- (void)setEnvelope:(id<DKDEnvelope>)envelope {
    if (envelope) {
        [self setObject:[envelope.sender string] forKey:@"sender"];
        [self setObject:[envelope.receiver string] forKey:@"receiver"];
        NSDate *time = envelope.time;
        if (time) {
            [self setObject:@([time timeIntervalSince1970]) forKey:@"time"];
        }
    } else {
        [self removeObjectForKey:@"sender"];
        [self removeObjectForKey:@"receiver"];
        //[self removeObjectForKey:@"time"];
    }
}

- (NSData *)signature {
    NSString *CT = [self objectForKey:@"signature"];
    return MKMBase64Decode(CT);
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        [self setObject:MKMBase64Encode(signature) forKey:@"signature"];
    } else {
        [self removeObjectForKey:@"signature"];
    }
}

@end
