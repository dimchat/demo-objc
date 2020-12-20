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
//  DIMSearchCommandProcessor.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/30.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMSearchCommand.h"

#import "DIMSearchCommandProcessor.h"

NSString * const kNotificationName_OnlineUsersUpdated = @"OnlineUsersUpdated";
NSString * const kNotificationName_SearchUsersUpdated = @"SearchUsersUpdated";

@implementation DIMSearchCommandProcessor

- (void)_parse:(DIMSearchCommand *)cmd {
    NSDictionary *result = cmd.results;
    if ([result count] == 0) {
        return;
    }
    DIMFacebook *facebook = self.facebook;
    id<MKMID> ID;
    id<MKMMeta> meta;
    NSString *key;
    NSDictionary *value;
    for (key in result) {
        value = [result objectForKey:key];
        ID = MKMIDFromString(key);
        meta = MKMMetaFromDictionary(value);
        if (!meta) {
            continue;
        }
        [facebook saveMeta:meta forID:ID];
    }
}

- (nullable id<DKDContent>)executeCommand:(DIMCommand *)content
                              withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content isKindOfClass:[DIMSearchCommand class]], @"search command error: %@", content);
    DIMSearchCommand *cmd = (DIMSearchCommand *)content;
    NSString *command = cmd.command;
    
    [self _parse:cmd];
    
    NSString *notificationName;
    if ([command isEqualToString:DIMCommand_Search]) {
        notificationName = kNotificationName_SearchUsersUpdated;
    } else if ([command isEqualToString:DIMCommand_OnlineUsers]) {
        notificationName = kNotificationName_OnlineUsersUpdated;
    } else {
        NSAssert(false, @"search command error: %@", cmd);
        return nil;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:notificationName object:self userInfo:content.dictionary];
    
    return nil;
}

@end
