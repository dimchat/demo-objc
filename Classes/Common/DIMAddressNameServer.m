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
//  DIMAddressNameService.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMAddressNameServer.h"

@interface DIMAddressNameServer () {
    
    NSMutableDictionary<NSString *, NSObject *> *_reserved;
    NSMutableDictionary<NSString *, id<MKMID>> *_caches;
}

@end

@implementation DIMAddressNameServer

- (instancetype)init {
    if (self = [super init]) {
        
        // reserved keywords
        char *KEYWORDS[] = {
                "all", "everyone", "anyone", "owner", "founder",
                // --------------------------------
                "dkd", "mkm", "dimp", "dim", "dimt",
                "rsa", "ecc", "aes", "des", "btc", "eth",
                // --------------------------------
                "crypto", "key", "symmetric", "asymmetric",
                "public", "private", "secret", "password",
                "id", "address", "meta", "profile",
                "entity", "user", "group", "contact",
                // --------------------------------
                "member", "admin", "administrator", "assistant",
                "main", "polylogue", "chatroom",
                "social", "organization",
                "company", "school", "government", "department",
                "provider", "station", "thing", "bot", "robot",
                // --------------------------------
                "message", "instant", "secure", "reliable",
                "envelope", "sender", "receiver", "time",
                "content", "forward", "command", "history",
                "keys", "data", "signature",
                // --------------------------------
                "type", "serial", "sn",
                "text", "file", "image", "audio", "video", "page",
                "handshake", "receipt", "block", "mute",
                "register", "suicide", "found", "abdicate",
                "invite", "expel", "join", "quit", "reset", "query",
                "hire", "fire", "resign",
                // --------------------------------
                "server", "client", "terminal", "local", "remote",
                "barrack", "cache", "transceiver",
                "ans", "facebook", "store", "messenger",
                "root", "supervisor",
        };
        
        // DIM founder
        id<MKMID> founder = MKMFounder();
        id<MKMID> anyone = MKMAnyone();
        id<MKMID> everyone = MKMEveryone();
        
        _caches = [[NSMutableDictionary alloc] init];
        
        // constant ANS records
        [_caches setObject:everyone forKey:@"all"];
        [_caches setObject:everyone forKey:@"everyone"];
        [_caches setObject:anyone forKey:@"anyone"];
        [_caches setObject:anyone forKey:@"owner"];
        [_caches setObject:founder forKey:@"founder"];
        
        // reserved names
        NSUInteger count = sizeof(KEYWORDS)/sizeof(KEYWORDS[0]);
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:count];
        char *name;
        for (NSUInteger index = 0; index < count; ++index) {
            name = KEYWORDS[index];
            [mDict setObject:@YES forKey:[NSString stringWithUTF8String:name]];
        }
        _reserved = mDict;
    }
    return self;
}

- (BOOL)isReserved:(NSString *)name {
    return [_reserved objectForKey:name];
}

- (nullable id<MKMID>)getID:(NSString *)name {
    return [_caches objectForKey:name];
}

- (NSArray<NSString *> *)getNames:(id<MKMID>)ID {
    return [_caches allKeysForObject:ID];
}

- (BOOL)cacheID:(id<MKMID>)ID withName:(NSString *)alias {
    if ([self isReserved:alias]) {
        // this name is reserved, cannot register
        return NO;
    }
    if (ID) {
        [_caches setObject:ID forKey:alias];
    } else {
        [_caches removeObjectForKey:alias];
    }
    return YES;
}

- (BOOL)saveID:(id<MKMID>)ID withName:(NSString *)alias {
    // TODO: save new record into database
    return [self cacheID:ID withName:alias];
}

- (NSUInteger)fixRecords:(NSDictionary<NSString *, NSString *> *)records {
    [_reserved removeObjectForKey:@"assistant"];
    //[_reserved removeObjectForKey:@"station"];
    NSUInteger count = 0;
    id<MKMID> ID;
    for (NSString *alias in records) {
        ID = MKMIDParse([records objectForKey:alias]);
        if (!alias || !ID) {
            // should not happen
            continue;;
        }
        if ([self saveID:ID withName:alias]) {
            count += 1;
        }
    }
    //[_reserved setObject:@(YES) forKey:@"station"];
    [_reserved setObject:@(YES) forKey:@"assistant"];
    return count;
}

@end
