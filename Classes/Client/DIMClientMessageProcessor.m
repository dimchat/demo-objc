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
//  DIMClientMessageProcessor.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"
#import "DIMReceiptCommand.h"

#import "DIMCreator.h"

#import "DIMClientMessenger.h"

#import "DIMClientMessageProcessor.h"

@implementation DIMClientMessageProcessor

- (id<DIMContentProcessorCreator>)createContentProcessorCreator {
    DIMClientContentProcessorCreator *creator;
    creator = [DIMClientContentProcessorCreator alloc];
    creator = [creator initWithFacebook:self.facebook messenger:self.messenger];
    return creator;
}

- (NSArray<id<DKDSecureMessage>> *)processSecure:(id<DKDSecureMessage>)sMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg {
    @try {
        return [super processSecure:sMsg withMessage:rMsg];
    } @catch (NSException *e) {
        NSString *errMsg = [e description];
        if ([errMsg containsString:@"receiver error"]) {
            // not mine? ignore it
            NSLog(@"ignore message for: %@", [rMsg receiver]);
            return nil;
        } else {
            @throw e;
        }
    }
}

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSArray<id<DKDContent>> *responses = [super processContent:content withMessage:rMsg];
    if ([responses count] == 0) {
        // respond nothing
        return nil;
    } else if ([[responses objectAtIndex:0] conformsToProtocol:@protocol(DKDHandshakeCommand)]) {
        // urgent command
        return responses;
    }
    id<MKMID> sender = [rMsg sender];
    id<MKMID> receiver = [rMsg receiver];
    id<MKMUser> user = [self.facebook selectLocalUserWithID:receiver];
    NSAssert(user, @"receiver error: %@", receiver);
    receiver = user.ID;
    DIMClientMessenger *messenger = [self messenger];
    // check responses
    for (id<DKDContent> res in responses) {
        if (!res) {
            // should not happen
            continue;
        } else if ([res conformsToProtocol:@protocol(DKDReceiptCommand)]) {
            if (sender.type == MKMEntityType_Station) {
                // no need to respond receipt to station
                continue;
            } else if (sender.type == MKMEntityType_Bot) {
                // no need to respond receipt to a bot
                continue;
            }
        } else if ([res conformsToProtocol:@protocol(DKDTextContent)]) {
            if (sender.type == MKMEntityType_Station) {
                // no need to respond text message to station
                continue;
            } else if (sender.type == MKMEntityType_Bot) {
                // no need to respond text message to a bot
                continue;
            }
        }
        // normal response
        [messenger sendContent:res sender:receiver receiver:sender priority:STDeparturePrioritySlower];
    }
    // DON'T respond to station directly
    return nil;
}

@end
