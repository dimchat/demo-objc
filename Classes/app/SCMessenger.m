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

#import "DIMFileContentProcessor.h"
#import "DIMSearchCommand.h"

#import "SCMessageDataSource.h"
#import "DIMAmanuensis.h"

#import "DIMFacebook+Extension.h"

#import "DIMMessenger+Extension.h"

#import "SCKeyStore.h"
#import "SCMessagePacker.h"
#import "SCMessageProcessor.h"
#import "SCMessageTransmitter.h"

#import "SCMessenger.h"

@interface SCMessenger () {

    id<DIMPacker> _packer;
    id<DIMProcessor> _processor;
    id<DIMTransmitter> _transmitter;

    DIMStation *_server;
    
    // query tables
    NSMutableDictionary<id<MKMID>, NSDate *> *_metaQueryTable;
    NSMutableDictionary<id<MKMID>, NSDate *> *_docQueryTable;
    NSMutableDictionary<id<MKMID>, NSDate *> *_groupQueryTable;
}

@end

@implementation SCMessenger

SingletonImplementations(SCMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        _packer = nil;
        _processor = nil;
        _transmitter = nil;

        // query tables
        _metaQueryTable  = [[NSMutableDictionary alloc] init];
        _docQueryTable   = [[NSMutableDictionary alloc] init];
        _groupQueryTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id<DIMCipherKeyDelegate>)keyCache {
    return [SCKeyStore sharedInstance];
}

- (id<DIMEntityDelegate>)barrack {
    return [DIMFacebook sharedInstance];
}

- (DIMFacebook *)facebook {
    return [DIMFacebook sharedInstance];
}

#pragma mark Message Packer

- (id<DIMPacker>)packer {
    if (!_packer) {
        _packer = [self createPacker];
    }
    return _packer;
}
- (id<DIMPacker>)createPacker {
    return [[SCMessagePacker alloc] initWithFacebook:self.facebook messenger:self];
}

#pragma mark Message Processor

- (id<DIMProcessor>)processor {
    if (!_processor) {
        _processor = [self createProcessor];
    }
    return _processor;
}
- (id<DIMProcessor>)createProcessor {
    return [[SCMessageProcessor alloc] initWithFacebook:self.facebook messenger:self];
}

#pragma mark Message Transmitter

- (id<DIMTransmitter>)transmitter {
    if (!_transmitter) {
        _transmitter = [self createTransmitter];
    }
    return _transmitter;
}
- (id<DIMTransmitter>)createTransmitter {
    return [[SCMessageTransmitter alloc] initWithFacebook:self.facebook messenger:self];
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
        // broadcast ID has no meta
        return NO;
    }
    
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_metaQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < QUERY_INTERVAL) {
        return NO;
    }
    [_metaQueryTable setObject:now forKey:ID];
    NSLog(@"querying meta of %@ fron network...", ID);

    id<DIMCommand> command = [[DIMMetaCommand alloc] initWithID:ID];
    return [self sendCommand:command];
}

- (BOOL)queryDocumentForID:(id<MKMID>)ID {
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has no document
        return NO;
    }
    
    // check for duplicated querying
    NSDate *now = [[NSDate alloc] init];
    NSDate *lastTime = [_docQueryTable objectForKey:ID];
    if ([now timeIntervalSince1970] - [lastTime timeIntervalSince1970] < QUERY_INTERVAL) {
        return NO;
    }
    [_docQueryTable setObject:now forKey:ID];
    NSLog(@"querying entity document of %@ fron network...", ID);

    id<DIMCommand> command = [[DIMDocumentCommand alloc] initWithID:ID];
    return [self sendCommand:command];
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
    
    id<DIMCommand> command = [[DIMQueryGroupCommand alloc] initWithGroup:group];
    BOOL checking = NO;
    for (id<MKMID> item in members) {
        if ([self sendContent:command receiver:item]) {
            checking = YES;
        }
    }
    return checking;
}

#pragma mark DIMTransmitter

- (BOOL)sendContent:(id<DKDContent>)content
             sender:(nullable id<MKMID>)from
           receiver:(id<MKMID>)to
           priority:(NSInteger)prior {
    return [self.transmitter sendContent:content sender:from receiver:to priority:prior];
}

- (BOOL)sendInstantMessage:(id<DKDInstantMessage>)iMsg priority:(NSInteger)prior {
    return [self.transmitter sendInstantMessage:iMsg priority:prior];
}

- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg priority:(NSInteger)prior {
    return [self.transmitter sendReliableMessage:rMsg priority:prior];
}

#pragma mark FPU

- (DIMFileContentProcessor *)fileContentProcessor {
    id<DIMContentProcessor> fpu = [self.processor processorForType:DKDContentType_File];
    NSAssert([fpu isKindOfClass:[DIMFileContentProcessor class]],
             @"failed to get file content processor");
    return (DIMFileContentProcessor *)fpu;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
            serializeContent:(id<DKDContent>)content
                     withKey:(id<MKMSymmetricKey>)password {
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContentProcessor *fpu = [self fileContentProcessor];
        [fpu uploadFileContent:(id<DIMFileContent>)content
                           key:password
                       message:iMsg];
    }
    return [super message:iMsg serializeContent:content withKey:password];
}

#pragma mark DKDSecureMessageDelegate

- (nullable id<DKDContent>)message:(id<DKDSecureMessage>)sMsg
              deserializeContent:(NSData *)data
                         withKey:(id<MKMSymmetricKey>)password {
    id<DKDContent> content = [super message:sMsg deserializeContent:data withKey:password];
    NSAssert(content, @"failed to deserialize message content: %@", sMsg);
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContentProcessor *fpu = [self fileContentProcessor];
        [fpu downloadFileContent:(id<DIMFileContent>)content
                             key:password
                         message:sMsg];
    }
    return content;
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    id reused = [password objectForKey:@"reused"];
    if (reused) {
        id<MKMID> receiver = iMsg.receiver;
        if (MKMIDIsGroup(receiver)) {
            // reuse key for grouped message
            return nil;
        }
        // remove before serialize key
        [password removeObjectForKey:@"reused"];
    }
    NSData *data = [super message:iMsg serializeKey:password];
    if (reused) {
        // put it back
        [password setObject:reused forKey:@"reused"];
    }
    return data;
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    id<MKMEncryptKey> key = [self.facebook publicKeyForEncryption:receiver];
    if (!key) {
        // save this message in a queue waiting receiver's meta response
        [self suspendMessage:iMsg];
        //NSAssert(false, @"failed to get encrypt key for receiver: %@", receiver);
        return nil;
    }
    return [super message:iMsg encryptKey:data forReceiver:receiver];
}

- (BOOL)saveMessage:(id<DKDInstantMessage>)iMsg {
    SCMessageDataSource *dataSource = [SCMessageDataSource sharedInstance];
    return [dataSource saveMessage:iMsg];
}

- (BOOL)suspendMessage:(id<DKDMessage>)msg {
    SCMessageDataSource *dataSource = [SCMessageDataSource sharedInstance];
    return [dataSource suspendMessage:msg];
}

@end
