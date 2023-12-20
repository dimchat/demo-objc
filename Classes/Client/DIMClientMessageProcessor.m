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
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"
#import "DIMReceiptCommand.h"

#import "DIMCreator.h"

#import "DIMClientArchivist.h"
#import "DIMClientFacebook.h"
#import "DIMClientMessenger.h"

#import "DIMClientMessageProcessor.h"

@implementation DIMClientMessageProcessor

// private
- (void)checkGroupTimes:(id<DKDContent>)content message:(id<DKDReliableMessage>)rMsg {
    id<MKMID> group = [content group];
    if (!group) {
        return;
    }
    DIMClientFacebook *facebook = [self facebook];
    DIMClientArchivist *archivist = [facebook archivist];
    if (!archivist) {
        NSAssert(false, @"should not happen");
        return;
    }
    NSDate *now = [[NSDate alloc] init];
    BOOL docUpdated = NO;
    BOOL memUpdated = NO;
    // check group document time
    NSDate *lastDocTime = [rMsg dateForKey:@"GDT" defaultValue:nil];
    if (lastDocTime) {
        if ([lastDocTime timeIntervalSince1970] > [now timeIntervalSince1970]) {
            // calibrate the clock
            lastDocTime = now;
        }
        docUpdated = [archivist setLastDocumentTime:lastDocTime forID:group];
    }
    // check group history time
    NSDate *lastHisTime = [rMsg dateForKey:@"GHT" defaultValue:nil];
    if (lastHisTime) {
        if ([lastHisTime timeIntervalSince1970] > [now timeIntervalSince1970]) {
            // calibrate the clock
            lastHisTime = now;
        }
        docUpdated = [archivist setLastHistoryTime:lastHisTime forID:group];
    }
    // check whether needs update
    if (docUpdated) {
        [self.facebook documentsForID:group];
    }
    if (memUpdated) {
        [archivist setLastActiveMember:rMsg.sender group:group];
        [self.facebook membersOfGroup:group];
    }
}

- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                 withReliableMessageMessage:(id<DKDReliableMessage>)rMsg {
    NSArray<id<DKDContent>> *responses = [super processContent:content
                                    withReliableMessageMessage:rMsg];
    
    // check group document & history times from the message
    // to make sure the group info synchronized
    [self checkGroupTimes:content message:rMsg];

    if ([responses count] == 0) {
        // respond nothing
        return nil;
    } else if ([[responses firstObject] conformsToProtocol:@protocol(DKDHandshakeCommand)]) {
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

- (id<DIMContentProcessorCreator>)createContentProcessorCreator {
    DIMClientContentProcessorCreator *creator;
    creator = [DIMClientContentProcessorCreator alloc];
    creator = [creator initWithFacebook:self.facebook messenger:self.messenger];
    return creator;
}

@end
