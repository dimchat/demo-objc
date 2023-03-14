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
//  DIMP
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

@interface DIMReceiptCommand ()

// original message info
@property (strong, nonatomic, nullable) id<DKDEnvelope> envelope;

@end

@implementation DIMReceiptCommand

- (instancetype)initWithText:(nullable NSString *)msg
                    envelope:(nullable id<DKDEnvelope>)env
                          sn:(NSUInteger)num
                   signature:(nullable NSString *)sig {
    if (self = [super initWithCommandName:DIMCommand_Receipt]) {
        // text message
        if (msg) {
            [self setObject:msg forKey:@"text"];
        }
        self.envelope = env;
        // envelope of the message responding to
        NSMutableDictionary<NSString *, id> *origin;
        if (env) {
            origin = [env dictionary];
        } else {
            origin = [[NSMutableDictionary alloc] init];
        }
        // sn of the message responding to
        if (num > 0) {
            [origin setObject:@(num) forKey:@"sn"];
        }
        // signature of the message responding to
        if (sig) {
            [origin setObject:sig forKey:@"signature"];
        }
        if ([origin count] > 0) {
            [self setObject:origin forKey:@"origin"];
        }
    }
    return self;
}

- (instancetype)initWithText:(NSString *)msg {
    return [self initWithText:msg envelope:nil sn:0 signature:nil];
}

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
                              sn:(NSUInteger)num
                       signature:(nullable NSString *)sig {
    return [self initWithText:nil envelope:env sn:num signature:sig];
}

- (NSString *)text {
    return [self stringForKey:@"text"];
}

- (NSDictionary<NSString *, id> *)origin {
    return [self objectForKey:@"origin"];
}

- (id<DKDEnvelope>)originEnvelope {
    if (!_envelope) {
        // origin: { sender: "...", receiver: "...", time: 0 }
        NSDictionary<NSString *, id> *origin = [self origin];
        if ([origin objectForKey:@"sender"] != nil) {
            self.envelope = DKDEnvelopeParse(origin);
        }
    }
    return _envelope;
}

- (unsigned long)originSerialNumber {
    NSDictionary<NSString *, id> *origin = [self origin];
    NSNumber *sn = [origin objectForKey:@"sn"];
    return [sn unsignedLongValue];
}

- (NSString *)originSignature {
    NSDictionary<NSString *, id> *origin = [self origin];
    return [origin objectForKey:@"signature"];
}

- (BOOL)matchMessage:(id<DKDInstantMessage>)iMsg {
    // check signature
    NSString *sig1 = [self originSignature];
    if (sig1) {
        // if contains signature, check it
        NSString *sig2 = [iMsg stringForKey:@"signature"];
        if (sig2) {
            if ([sig1 length] > 8) {
                sig1 = [sig1 substringFromIndex:8];
            }
            if ([sig2 length] > 8) {
                sig2 = [sig2 substringFromIndex:8];
            }
            return [sig1 isEqualToString:sig2];
        }
    }
    // check envelope
    id<DKDEnvelope> env1 = [self originEnvelope];
    if (env1) {
        // if contains envelope, check it
        return [iMsg.envelope isEqual:env1];
    }
    // check serial number
    // (only the original message's receiver can know this number)
    unsigned long sn1 = [self originSerialNumber];
    unsigned long sn2 = [iMsg.content serialNumber];
    return sn1 == sn2;
}

@end
