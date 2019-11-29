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

#import <DIMSDK/DIMSDK.h>

#import "NSNotificationCenter+Extension.h"
#import "DIMFacebook+Extension.h"

#import "NSObject+JsON.h"
#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "NSString+Crypto.h"
#import "DIMTerminal+Response.h"
#import "LocalDatabaseManager.h"

@implementation DIMTerminal (Response)

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
            [[DIMFacebook sharedInstance] user:user.ID addContact:ID];
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
    [[DIMFacebook sharedInstance] user:user.ID addContact:ID];
}

@end
