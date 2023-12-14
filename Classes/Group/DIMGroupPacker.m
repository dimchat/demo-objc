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
//  DIMGroupPacker.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMCommonMessenger.h"

#import "DIMGroupDelegate.h"

#import "DIMGroupPacker.h"

@interface DIMGroupPacker ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@end

@implementation DIMGroupPacker

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (DIMMessenger *)messenger {
    return [self.delegate messenger];
}

- (id<DKDReliableMessage>)packMessageWithContent:(id<DKDContent>)content
                                          sender:(id<MKMID>)from {
    id<DKDEnvelope> envelope = DKDEnvelopeCreate(from, MKMAnyone(), nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(envelope, content);
    [iMsg setString:content.group forKey:@"group"];  // expose group ID
    return [self encryptAndSignMessage:iMsg];
}

- (id<DKDReliableMessage>)encryptAndSignMessage:(id<DKDInstantMessage>)iMsg {
    DIMMessenger *messenger = [self messenger];
    // encrypt for receiver
    id<DKDSecureMessage> sMsg = [messenger encryptMessage:iMsg];
    if (!sMsg) {
        NSAssert(false, @"failed to encrypt message: %@ => %@, %@", iMsg.sender, iMsg.receiver, iMsg.group);
        return nil;
    }
    // sign for sender
    id<DKDReliableMessage> rMsg = [messenger signMessage:sMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to sign message: %@ => %@, %@", iMsg.sender, iMsg.receiver, iMsg.group);
        return nil;
    }
    // OK
    return rMsg;
}

- (NSArray<id<DKDInstantMessage>> *)splitInstantMessage:(id<DKDInstantMessage>)iMsg
                                                members:(NSArray<id<MKMID>> *)members {
    NSUInteger count = [members count];
    if (count == 0) {
        NSAssert(false, @"members should not be empty");
        return nil;
    }
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:(count - 1)];
    id<MKMID> sender = [iMsg sender];
    
    NSMutableDictionary *info;
    id<DKDInstantMessage> item;
    for (id<MKMID> receiver in members) {
        if ([sender isEqual:receiver]) {
            NSLog(@"skip cycled message: %@, %@", receiver, iMsg.group);
            continue;
        }
        NSLog(@"split group message for member: %@", receiver);
        info = [iMsg dictionary:NO];
        // replace 'receiver' with member ID
        [info setObject:receiver.string forKey:@"receiver"];
        item = DKDInstantMessageParse(info);
        if (!item) {
            NSAssert(false, @"failed to repack message: %@", receiver);
            continue;
        }
        [messages addObject:item];
    }
    
    return messages;
}

- (NSArray<id<DKDReliableMessage>> *)splitReliableMessage:(id<DKDReliableMessage>)rMsg
                                                  members:(NSArray<id<MKMID>> *)members {
    NSUInteger count = [members count];
    if (count == 0) {
        NSAssert(false, @"members should not be empty");
        return nil;
    }
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:(count - 1)];
    id<MKMID> sender = [rMsg sender];
    
    NSAssert(![rMsg objectForKey:@"key"], @"should not happen");
    NSMutableDictionary *keys;
    NSDictionary *keyMap = [rMsg encryptedKeys];
    if (!keyMap) {
        keys = [[NSMutableDictionary alloc] init];
    } else if ([keyMap isKindOfClass:[NSMutableDictionary class]]) {
        keys = (NSMutableDictionary *)keyMap;
    } else {
        keys = [keyMap mutableCopy];
    }
    // TODO: get key digest
    
    id keyData;  // Base-64
    NSMutableDictionary *info;
    id<DKDReliableMessage> item;
    for (id<MKMID> receiver in members) {
        if ([sender isEqual:receiver]) {
            NSLog(@"skip cycled message: %@, %@", receiver, rMsg.group);
            continue;
        }
        NSLog(@"split group message for member: %@", receiver);
        info = [rMsg dictionary:NO];
        // replace 'receiver' with member ID
        [info setObject:receiver.string forKey:@"receiver"];
        // fetch encrypted key data
        [info removeObjectForKey:@"keys"];
        keyData = [keys objectForKey:receiver.string];
        if (keyData) {
            [info setObject:keyData forKey:@"key"];
        }
        item = DKDReliableMessageParse(info);
        if (!item) {
            NSAssert(false, @"failed to repack message: %@", receiver);
            continue;
        }
        [messages addObject:item];
    }
    
    return messages;
}

@end
