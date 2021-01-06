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
//  SCMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/13.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMSearchCommand.h"

#import "SCMessageDataSource.h"
#import "DIMAmanuensis.h"

#import "DIMFacebook+Extension.h"

#import "DIMMessenger+Extension.h"

#import "SCKeyStore.h"
#import "SCMessagePacker.h"
#import "SCMessageProcessor.h"

#import "SCMessenger.h"

@implementation SCMessenger

SingletonImplementations(SCMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // query tables
        _metaQueryTable    = [[NSMutableDictionary alloc] init];
        _profileQueryTable = [[NSMutableDictionary alloc] init];
        _groupQueryTable   = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id<DIMMessengerDataSource>)dataSource {
    id<DIMMessengerDataSource> delegate = [super dataSource];
    if (!delegate) {
        delegate = [SCMessageDataSource sharedInstance];
    }
    return delegate;
}

- (id<DIMCipherKeyDelegate>)keyCache {
    id<DIMCipherKeyDelegate> delegate = [super keyCache];
    if (!delegate) {
        delegate = [SCKeyStore sharedInstance];
    }
    return delegate;
}

- (DIMFacebook *)createFacebook {
    return [DIMFacebook sharedInstance];
}

- (DIMMessagePacker *)createMessagePacker {
    return [[SCMessagePacker alloc] initWithMessenger:self];
}

- (DIMMessageProcessor *)createMessageProcessor {
    return [[SCMessageProcessor alloc] initWithMessenger:self];
}

- (DIMStation *)currentServer {
    return _server;
}

- (void)setCurrentServer:(DIMStation *)server {
    _server = server;
}

#define QUERY_INTERVAL  120  // query interval (2 minutes)

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has not meta
        return YES;
    }
    
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_metaQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < QUERY_INTERVAL) {
        return NO;
    }
    [_metaQueryTable setObject:now forKey:ID];
    NSLog(@"querying meta of %@ fron network...", ID);

    DIMCommand *cmd = [[DIMMetaCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)queryProfileForID:(id<MKMID>)ID {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_profileQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < QUERY_INTERVAL) {
        return NO;
    }
    [_profileQueryTable setObject:now forKey:ID];
    NSLog(@"querying profile of %@ fron network...", ID);

    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID];
    return [self sendCommand:cmd];
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMember:(id<MKMID>)member {
    return [self queryGroupForID:group fromMembers:@[member]];
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMembers:(NSArray<id<MKMID>> *)members {
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_groupQueryTable objectForKey:group];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < QUERY_INTERVAL) {
        return NO;
    }
    [_groupQueryTable setObject:now forKey:group];
    
    DIMCommand *cmd = [[DIMQueryGroupCommand alloc] initWithGroup:group];
    BOOL checking = NO;
    for (id<MKMID>item in members) {
        if ([self sendContent:cmd receiver:item]) {
            checking = YES;
        }
    }
    return checking;
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    if ([password objectForKey:@"reused"]) {
        id<MKMID> receiver = iMsg.receiver;
        if (MKMIDIsGroup(receiver)) {
            // reuse key for grouped message
            return nil;
        }
    }
    return [super message:iMsg serializeKey:password];
}

@end
