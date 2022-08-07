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
//  DIMMessenger+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMSearchCommand.h"

#import "SCMessenger.h"

#import "DIMMessenger+Extension.h"

NSString * const kNotificationName_MessageSent       = @"MessageSent";
NSString * const kNotificationName_SendMessageFailed = @"SendMessageFailed";

@implementation DIMMessenger (Extension)

+ (instancetype)sharedInstance {
    return [SCMessenger sharedInstance];
}

- (DIMFacebook *)facebook {
    NSAssert(false, @"implement me!");
    return nil;
}

- (DIMStation *)currentServer {
    NSAssert(false, @"implement me!");
    return nil;
}

- (void)setCurrentServer:(DIMStation *)server {
    NSAssert(false, @"implement me!");
}

- (BOOL)sendContent:(id<DKDContent>)content receiver:(id<MKMID>)receiver {
    return [self sendContent:content sender:nil receiver:receiver priority:1];
}

- (BOOL)sendContent:(id<DKDContent>)content
             sender:(nullable id<MKMID>)from
           receiver:(id<MKMID>)to
           priority:(NSInteger)prior {
    return [self.transmitter sendContent:content sender:from receiver:to priority:prior];
}

/**
 *  Send instant message (encrypt and sign) onto DIM network
 *
 * @param iMsg - instant message
 * @param prior - task priority
 * @return NO on data/delegate error
 */
- (BOOL)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                  priority:(NSInteger)prior {
    return [self.transmitter sendInstantMessage:iMsg priority:prior];
}

- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg
                   priority:(NSInteger)prior {
    return [self.transmitter sendReliableMessage:rMsg priority:prior];
}

- (BOOL)broadcastContent:(id<DKDContent>)content {
    NSAssert(self.currentServer, @"station not connected yet");
    // broadcast IDs
    id<MKMID> everyone = MKMEveryone();
    [content setGroup:everyone];
    return [self sendContent:content receiver:everyone];
}

- (BOOL)sendCommand:(DIMCommand *)command {
    DIMStation *server = [self currentServer];
    NSAssert(server, @"server not connected yet");
    return [self sendContent:command receiver:server.ID];
}

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryDocumentForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMember:(id<MKMID>)member {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)queryGroupForID:(id<MKMID>)group fromMembers:(NSArray<id<MKMID>> *)members {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)postDocument:(id<MKMDocument>)doc withMeta:(nullable id<MKMMeta>)meta {
    [doc removeObjectForKey:@"expires"];
    DIMCommand *command = [[DIMDocumentCommand alloc] initWithID:doc.ID meta:meta document:doc];
    return [self sendCommand:command];
}

- (BOOL)broadcastVisa:(id<MKMVisa>)visa {
    DIMUser *user = [self.facebook currentUser];
    id<MKMID> ID = user.ID;
    if (![visa.ID isEqual:ID]) {
        NSAssert(false, @"visa ID not match: %@, %@", ID, visa.ID);
        return NO;
    }
    DIMCommand *command = [[DIMDocumentCommand alloc] initWithID:ID document:visa];
    NSArray<id<MKMID>> *contacts = user.contacts;
    BOOL OK = YES;
    for (id<MKMID> contact in contacts) {
        if (!MKMIDIsUser(contact)) {
            NSLog(@"%@ is not a user, do not broadcaset document to it", contact);
            continue;
        }
        if (![self sendContent:command receiver:contact]) {
            OK = NO;
        }
    }
    return OK;
}

- (BOOL)postContacts:(NSArray<id<MKMID>> *)contacts {
    DIMUser *user = [self.facebook currentUser];
    NSAssert([contacts count] > 0, @"contacts cannot be empty");
    // generate password
    id<MKMSymmetricKey> password = MKMSymmetricKeyGenerate(MKMAlgorithmAES);
    // encrypt contacts
    NSData *data = MKMUTF8Encode(MKMJSONEncode(contacts));
    data = [password encrypt:data];
    // encrypt key
    NSData *key = MKMUTF8Encode(MKMJSONEncode(password));
    key = [user encrypt:key];
    // pack 'contacts' command
    DIMStorageCommand *command;
    command = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    command.ID = user.ID;
    command.data = data;
    command.key = key;
    // send to station
    return [self sendCommand:command];
}

- (BOOL)queryContacts{
    DIMUser *user = [self.facebook currentUser];
    // pack 'contacts' command
    DIMStorageCommand *command;
    command = [[DIMStorageCommand alloc] initWithTitle:DIMCommand_Contacts];
    command.ID = user.ID;
    // send to station
    return [self sendCommand:command];
}

- (BOOL)queryMuteList{
    DIMCommand *command = [[DIMMuteCommand alloc] initWithList:nil];
    return [self sendCommand:command];
}

@end

@implementation DIMMessenger (Station)

@dynamic delegate;
@dynamic transmitter;

- (BOOL)sendPackageData:(NSData *)data priority:(NSInteger)prior {
    return [self.delegate sendPackageData:data priority:prior];
}

- (nullable NSURL *)uploadData:(NSData *)CT forMessage:(id<DKDInstantMessage>)iMsg {
    return [self.delegate uploadData:CT forMessage:iMsg];
}

- (nullable NSData *)downloadData:(NSURL *)url forMessage:(id<DKDInstantMessage>)iMsg {
    return [self.delegate downloadData:url forMessage:iMsg];
}

@end
