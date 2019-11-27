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
//  DIMTerminal+Request.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSNotificationCenter+Extension.h"
#import "DKDInstantMessage+Extension.h"

#import "DIMFacebook.h"
#import "DIMMessenger.h"
#import <DIMClient/DIMClient.h>
#import "DIMServer.h"
#import "DIMTerminal+Request.h"

NSString * const kNotificationName_MessageSent       = @"MessageSent";
NSString * const kNotificationName_SendMessageFailed = @"SendMessageFailed";

@implementation DIMTerminal (Packing)

- (nullable DIMInstantMessage *)sendContent:(DIMContent *)content
                                         to:(DIMID *)receiver {
    if (!self.currentUser) {
        NSLog(@"not login, drop message content: %@", content);
        // TODO: save the message content in waiting queue
        return nil;
    }
    if (![receiver isBroadcast] && !DIMMetaForID(receiver)) {
        // TODO: check profile.key
        NSLog(@"cannot get public key for receiver: %@", receiver);
        // NOTICE: if meta for sender not found,
        //         the client will query it automatically
        // TODO: save the message content in waiting queue
        return nil;
    }
    DIMID *sender = self.currentUser.ID;
    
    // make instant message
    DIMInstantMessage *iMsg = DKDInstantMessageCreate(content, sender, receiver, nil);
    // callback
    DIMTransceiverCallback callback;
    callback = ^(DIMReliableMessage *rMsg, NSError *error) {
        NSString *name = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            iMsg.state = DIMMessageState_Error;
            iMsg.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", iMsg, rMsg);
            name = kNotificationName_MessageSent;
            iMsg.state = DIMMessageState_Accepted;
        }
        
        NSDictionary *info = @{@"message": iMsg};
        [NSNotificationCenter postNotificationName:name
                                            object:self
                                          userInfo:info];
    };
    // send out
    if ([[DIMMessenger sharedInstance] sendInstantMessage:iMsg callback:callback dispersedly:YES]) {
        return iMsg;
    } else {
        NSLog(@"failed to send message: %@", iMsg);
        return nil;
    }
}

- (void)sendCommand:(DIMCommand *)cmd {
    if (!_currentStation) {
        NSLog(@"not connect, drop command: %@", cmd);
        // TODO: save the command in waiting queue
        return ;
    }
    [self sendContent:cmd to:_currentStation.ID];
}

- (void)broadcastContent:(DIMContent *)content {
    if (!_currentStation) {
        NSLog(@"not connect, drop content: %@", content);
        // TODO: save the command in waiting queue
        return ;
    }
    // broadcast IDs
    DIMID *everyone = DIMIDWithString(@"everyone@everywhere");
    DIMID *anyone = DIMIDWithString(@"anyone@anywhere");
    [content setGroup:everyone];
    [self sendContent:content to:anyone];
}

@end

@implementation DIMTerminal (Request)

- (BOOL)login:(DIMUser *)user {
    if (!user || [self.currentUser isEqual:user]) {
        NSLog(@"user not change");
        return NO;
    }
    
    // clear session
    _session = nil;
    
    NSLog(@"logout: %@", self.currentUser);
    self.currentUser = user;
    NSLog(@"login: %@", user);
    
    // add to the list of this client
    if (![_users containsObject:user]) {
        [_users addObject:user];
    }
    return YES;
}

- (void)onHandshakeAccepted:(NSString *)session {
    // post current profile to station
    DIMProfile *profile = self.currentUser.profile;
    if (profile) {
        [self postProfile:profile];
    }
    // post contacts(encrypted) to station
    NSArray<DIMID *> *contacts = self.currentUser.contacts;
    if (contacts) {
        [self postContacts:contacts];
    }
}

- (void)postProfile:(DIMProfile *)profile {
    DIMUser *user = [self currentUser];
    DIMID *ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return ;
    }
    
    DIMMeta *meta = user.meta;
    if (![profile verify:meta.key]){
        return ;
    }
    
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:profile.ID
                                                    profile:profile];
    [self sendCommand:cmd];
}

- (void)broadcastProfile:(DIMProfile *)profile {
    DIMUser *user = [self currentUser];
    DIMID *ID = user.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return ;
    }
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:profile.ID
                                                    profile:profile];
    NSArray<DIMID *> *contacts = user.contacts;
    for (DIMID *contact in contacts) {
        [self sendContent:cmd to:contact];
    }
}

- (void)postContacts:(NSArray<DIMID *> *)contacts {
    DIMUser *user = [self currentUser];
    DIMID *ID = user.ID;
    NSAssert([contacts count] > 0, @"contacts cannot be empty");
    // generate password
    DIMSymmetricKey *password = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
    // encrypt contacts
    NSData *data = [contacts jsonData];
    data = [password encrypt:data];
    // encrypt key
    NSData *key = [password jsonData];
    key = [user encrypt:key];
    // pack 'contacts' command
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"contacts"];
    [cmd setObject:ID forKey:@"ID"];
    [cmd setObject:[data base64Encode] forKey:@"data"];
    [cmd setObject:[key base64Encode] forKey:@"key"];
    // send to station
    [self sendCommand:cmd];
}

-(void)getContacts{
    
    DIMUser *user = [self currentUser];
    DIMID *ID = user.ID;
    
    // pack 'contacts' command
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"contacts"];
    [cmd setObject:ID forKey:@"ID"];
    // send to station
    [self sendCommand:cmd];
}

-(void)getMuteList{
    
    DIMCommand *cmd = [[DIMMuteCommand alloc] initWithList:nil];
    [self sendCommand:cmd];
}

- (void)queryMetaForID:(DIMID *)ID {
    NSAssert(![ID isEqual:_currentStation.ID], @"should not query meta: %@", ID);
    if ([ID isBroadcast]) {
        //NSAssert(false, @"should not query meta for broadcast ID: %@", ID);
        return;
    }
    DIMCommand *cmd = [[DIMMetaCommand alloc] initWithID:ID];
    [self sendCommand:cmd];
}

- (void)queryProfileForID:(DIMID *)ID {
    if ([ID isBroadcast]) {
        //NSAssert(false, @"should not query profile for broadcast ID: %@", ID);
        return;
    }
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID];
    [self sendCommand:cmd];
}

- (void)queryOnlineUsers {
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"users"];
    [self sendCommand:cmd];
}

- (void)searchUsersWithKeywords:(NSString *)keywords {
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"search"];
    [cmd setObject:keywords forKey:@"keywords"];
    [self sendCommand:cmd];
}

@end
