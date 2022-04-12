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
//  DIMStorageCommandProcessor.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/30.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook+Extension.h"

#import "DIMStorageCommandProcessor.h"

@implementation DIMStorageCommandProcessor

- (NSArray<id<DKDContent>> *)saveContacts:(NSArray *)contacts forUser:(DIMUser *)user {
    DIMFacebook *facebook = self.facebook;
    id<MKMID> ID;
    for (NSString *item in contacts) {
        ID = MKMIDFromString(item);
        // request contact/group meta and save to local
        [facebook metaForID:ID];
        [facebook user:user.ID addContact:ID];
    }
    // no need to respond this command
    return nil;
}

- (NSArray<id<DKDContent>> *)decryptContactsData:(NSData *)data withKey:(NSData *)key forUser:(DIMUser *)user {
    // decrypt key
    key = [user decrypt:key];
    id dict = MKMJSONDecode(MKMUTF8Decode(key));
    id<MKMSymmetricKey> password = MKMSymmetricKeyFromDictionary(dict);
    // decrypt data
    data = [password decrypt:data];
    NSArray *contacts = MKMJSONDecode(MKMUTF8Decode(data));
    NSAssert(contacts, @"failed to decrypt contacts");
    return [self saveContacts:contacts forUser:user];
}

- (NSArray<id<DKDContent>> *)processContactsCommand:(DIMStorageCommand *)cmd sender:(id<MKMID>)sender {
    DIMUser *user = [self.facebook currentUser];
    if (![user.ID isEqual:cmd.ID]) {
        NSAssert(false, @"current user %@ not match %@ contacts not saved", user, cmd.ID);
        return nil;
    }
    
    NSArray *contacts = cmd.contacts;
    if ([contacts count] > 0) {
        return [self saveContacts:contacts forUser:user];
    }
    
    NSData *data = cmd.data;
    NSData *key = cmd.key;
    if (data && key) {
        return [self decryptContactsData:data withKey:key forUser:user];
    }
    
    // NOTICE: the client will post contacts to a statioin initiatively,
    //         cannot be query
    NSAssert(false, @"contacts command error: %@", cmd);
    return nil;
}

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content isKindOfClass:[DIMStorageCommand class]], @"storage command error: %@", content);
    DIMStorageCommand *cmd = (DIMStorageCommand *)content;
    NSString *title = cmd.title;
    if ([title isEqualToString:DIMCommand_Contacts]) {
        return [self processContactsCommand:cmd sender:rMsg.sender];
    }
    NSAssert(false, @"Storage command (title: %@) not support yet!", title);
    // respond nothing (DON'T respond storage command directly)
    return nil;
}

@end

#pragma mark - Contacts

@implementation DIMStorageCommand (Contacts)

- (nullable NSArray<id<MKMID>> *)contacts {
    NSArray *array = [self objectForKey:@"contacts"];
    if (array) {
        return MKMIDConvert(array);
    }
    return nil;
}

- (void)setContacts:(NSArray<id<MKMID>> *)contacts {
    [self setObject:MKMIDRevert(contacts) forKey:@"contacts"];
}

@end
