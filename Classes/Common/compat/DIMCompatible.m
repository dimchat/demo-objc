// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
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
//  DIMCompatible.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/11.
//

#import "DIMCompatible.h"

@implementation DIMCompatible

+ (void)fixMetaAttachment:(id<DKDReliableMessage>)rMsg {
    NSMutableDictionary *meta = [rMsg objectForKey:@"meta"];
    if (meta) {
        [self fixMetaVersion:meta];
    }
}

+ (void)fixMetaVersion:(NSMutableDictionary<NSString *, id> *)meta {
    id version = [meta objectForKey:@"version"];
    if (version == nil) {
        version = [meta objectForKey:@"type"];
        [meta setObject:version forKey:@"version"];
    } else if (![meta objectForKey:@"type"]) {
        [meta setObject:version forKey:@"type"];
    }
}

+ (id<DKDCommand>)fixCommand:(id<DKDCommand>)content {
    // 1. fix 'cmd'
    content = [self fixCmd:content];
    // 2. fix other commands
    if ([content conformsToProtocol:@protocol(DKDMetaCommand)]) {
        NSMutableDictionary *meta = [content objectForKey:@"meta"];
        if (meta) {
            [self fixMetaVersion:meta];
        }
    } else if ([content conformsToProtocol:@protocol(DKDReceiptCommand)]) {
        [self fixReceiptCommand:(id<DKDReceiptCommand>)content];
    }
    // OK
    return content;
}

+ (id<DKDCommand>)fixCmd:(id<DKDCommand>)content {
    NSString *cmd = [content objectForKey:@"cmd"];
    if (!cmd) {
        cmd = [content objectForKey:@"command"];
        [content setObject:cmd forKey:@"cmd"];
    } else if (![content objectForKey:@"command"]) {
        [content setObject:cmd forKey:@"command"];
        content = DKDCommandParse(content.dictionary);
    }
    return content;
}

+ (void)fixReceiptCommand:(id<DKDReceiptCommand>)content {
    // TODO: check for v2.0
}

@end
