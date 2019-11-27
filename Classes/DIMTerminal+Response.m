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
//  DIMTerminal+Response.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"

#import "DIMFacebook.h"
#import "NSObject+JsON.h"
#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "NSString+Crypto.h"
#import "DIMTerminal+Response.h"
#import "DIMMuteCommand.h"
#import "LocalDatabaseManager.h"

NSString * const kNotificationName_OnlineUsersUpdated = @"OnlineUsersUpdated";
NSString * const kNotificationName_SearchUsersUpdated = @"SearchUsersUpdated";

@implementation DIMTerminal (Response)

- (void)processHandshakeCommand:(DIMHandshakeCommand *)cmd {
    DIMHandshakeState state = cmd.state;
    if (state == DIMHandshake_Success) {
        // handshake OK
        NSLog(@"handshake accepted: %@", self.currentUser);
        NSLog(@"current station: %@", self);
        [_currentStation handshakeAccepted:YES session:_session];
        [self onHandshakeAccepted:_session];
    } else if (state == DIMHandshake_Again) {
        // update session and handshake again
        NSString *session = cmd.sessionKey;
        NSLog(@"session %@ -> %@", _session, session);
        _session = session;
        [_currentStation handshakeWithSession:session];
    } else {
        NSLog(@"handshake rejected: %@", cmd);
        [_currentStation handshakeAccepted:NO session:nil];
    }
}

- (void)processMetaCommand:(DIMMetaCommand *)cmd {
    // check meta
    DIMMeta *meta = cmd.meta;
    if ([meta matchID:cmd.ID]) {
        NSLog(@"got new meta for %@", cmd.ID);
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        [facebook saveMeta:cmd.meta forID:cmd.ID];
    } else {
        NSAssert(meta == nil, @"meta error: %@", cmd);
    }
}

- (void)processProfileCommand:(DIMProfileCommand *)cmd {
    // check meta
    [self processMetaCommand:cmd];
    
    // check profile
    DIMProfile *profile = cmd.profile;
    if (profile) {
        NSAssert([profile.ID isEqual:cmd.ID], @"profile not match ID: %@", cmd);
        NSLog(@"got new profile for %@", cmd.ID);
        
        // update local profile
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        [facebook saveProfile:profile];
    }
}

- (void)processOnlineUsersCommand:(DIMCommand *)cmd {
    NSArray *users = [cmd objectForKey:@"users"];
    NSDictionary *info = @{@"users": users};
    [NSNotificationCenter postNotificationName:kNotificationName_OnlineUsersUpdated object:self userInfo:info];
}

- (void)processSearchUsersCommand:(DIMCommand *)cmd {
    NSArray *users = [cmd objectForKey:@"users"];
    NSDictionary *results = [cmd objectForKey:@"results"];
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (users) {
        [mDict setObject:users forKey:@"users"];
    }
    if (results) {
        [mDict setObject:results forKey:@"results"];
    }
    [NSNotificationCenter postNotificationName:kNotificationName_SearchUsersUpdated object:self userInfo:mDict];
}

-(void)processMuteCommand:(DIMMuteCommand *)cmd{
    
    NSArray *muteList = cmd.list;
    
    DIMUser *user = [self currentUser];
    LocalDatabaseManager *manager = [LocalDatabaseManager sharedInstance];
    [manager unmuteAllConversationForUser:user.ID];
    
    for(NSString *conversationString in muteList){
        
        DIMID *conversationID = DIMIDWithString(conversationString);
        [manager muteConversation:conversationID forUser:user.ID];
    }
}

- (void)processContactsCommand:(DIMCommand *)cmd{
    
    DIMUser *user = [self currentUser];
    
    NSString *dataStr = [cmd objectForKey:@"data"];
    NSString *keyStr = [cmd objectForKey:@"key"];
    
    NSData *data = [dataStr base64Decode];
    NSData *key = [keyStr base64Decode];
    
    key = [user decrypt:key];
    DIMSymmetricKey *password = MKMSymmetricKeyFromDictionary([key jsonDictionary]);
    
    data = [password decrypt:data];
    NSArray *contacts = [data jsonArray];
    
    for(NSString *address in contacts){
        
        DIMID *ID = DIMIDWithString(address);
        
        if(ID.type == MKMNetwork_Group){
            
            //Request Group Meta and save to local
            DIMMetaForID(ID);
            [[DIMFacebook sharedInstance] user:user addContact:ID];
        }else{
            [self addUserToContact:address];
        }
    }
}

-(void)addUserToContact:(NSString *)itemString{
    
    DIMID *ID = DIMIDWithString(itemString);
    
    DIMUser *user = self.currentUser;
    DIMMeta *meta = DIMMetaForID(user.ID);
    DIMProfile *profile = user.profile;
    DIMCommand *cmd;
    if (profile) {
        cmd = [[DIMProfileCommand alloc] initWithID:user.ID
                                               meta:meta
                                            profile:profile];
    } else {
        cmd = [[DIMMetaCommand alloc] initWithID:user.ID meta:meta];
    }
    [self sendContent:cmd to:ID];
    
    // add to contacts
    [[DIMFacebook sharedInstance] user:user addContact:ID];
}

@end
