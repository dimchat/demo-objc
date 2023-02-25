// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DKDInstantMessage+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/21.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

#import "DKDInstantMessage+Extension.h"

@implementation DIMContent (State)

- (DIMMessageState)state {
    NSNumber *number = [self objectForKey:@"state"];
    return [number unsignedIntegerValue];
}

- (void)setState:(DIMMessageState)state {
    [self setObject:@(state) forKey:@"state"];
}

- (NSString *)error {
    return [self objectForKey:@"error"];
}

- (void)setError:(NSString *)error {
    if (error) {
        [self setObject:error forKey:@"error"];
    } else {
        [self removeObjectForKey:@"error"];
    }
}

@end

@implementation DIMInstantMessage (Extension)

- (BOOL)matchReceipt:(DIMReceiptCommand *)content {
    
    // check signature
    NSString *sig1 = [content objectForKey:@"signature"];
    NSString *sig2 = [self objectForKey:@"signature"];
    if (sig1.length >= 8 && sig2.length >= 8) {
        // if contains signature, check it
        sig1 = [sig1 substringToIndex:8];
        sig2 = [sig2 substringToIndex:8];
        return [sig1 isEqualToString:sig2];
    }
    
    // check envelope
    id<DKDEnvelope> env1 = content.envelope;
    id<DKDEnvelope> env2 = self.envelope;
    if (env1) {
        // if contains envelope, check it
        return [env1 isEqual:env2];
    }
    
    // check serial number
    // (only the original message's receiver can know this number)
    return content.serialNumber == self.content.serialNumber;
}

@end
