// license: https://mit-license.org
//
//  SeChat : Secure/secret Chat Application
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  SCProcessorFactory.m
//  DIMClient
//
//  Created by Albert Moky on 2021/11/22.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import "DIMSearchCommand.h"
#import "DIMReportCommand.h"

#import "DIMDefaultProcessor.h"
#import "DIMFileContentProcessor.h"

#import "DIMReceiptCommandProcessor.h"
#import "DIMMuteCommandProcessor.h"
#import "DIMBlockCommandProcessor.h"

#import "DIMHandshakeCommandProcessor.h"
#import "DIMLoginCommandProcessor.h"

#import "DIMStorageCommandProcessor.h"
#import "DIMSearchCommandProcessor.h"

#import "SCProcessorFactory.h"

@implementation SCProcessorFactory

- (DIMContentProcessor *)createProcessorWithType:(DKDContentType)type {
    // file
    if (type == DKDContentType_File) {
        return [[DIMFileContentProcessor alloc] initWithMessenger:self.messenger];
    } else if (type == DKDContentType_Image || type == DKDContentType_Audio || type == DKDContentType_Video) {
        // TODO: shared the same processor with 'FILE'?
        return [[DIMFileContentProcessor alloc] initWithMessenger:self.messenger];
    }
    DIMContentProcessor *cpu = [super createProcessorWithType:type];
    if (!cpu) {
        // unknown
        return [[DIMDefaultContentProcessor alloc] initWithMessenger:self.messenger];
    }
    return cpu;
}

- (DIMCommandProcessor *)createProcessorWithType:(DKDContentType)type command:(NSString *)name {
    // receipt
    if ([name isEqualToString:DIMCommand_Receipt]) {
        return [[DIMReceiptCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // mute
    if ([name isEqualToString:DIMCommand_Mute]) {
        return [[DIMMuteCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // block
    if ([name isEqualToString:DIMCommand_Block]) {
        return [[DIMBlockCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // handshake
    if ([name isEqualToString:DIMCommand_Handshake]) {
        return [[DIMHandshakeCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // login
    if ([name isEqualToString:DIMCommand_Login]) {
        return [[DIMLoginCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // storage
    if ([name isEqualToString:DIMCommand_Storage]) {
        return [[DIMStorageCommandProcessor alloc] initWithMessenger:self.messenger];
    } else if ([name isEqualToString:@"contacts"] || [name isEqualToString:@"private_key"]) {
        // TODO: shared the same processor with 'storage'?
        return [[DIMStorageCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // search
    if ([name isEqualToString:DIMCommand_Search]) {
        return [[DIMSearchCommandProcessor alloc] initWithMessenger:self.messenger];
    } else if ([name isEqualToString:DIMCommand_OnlineUsers]) {
        // TODO: shared the same processor with 'search'?
        return [[DIMSearchCommandProcessor alloc] initWithMessenger:self.messenger];
    }
    // others
    return [super createProcessorWithType:type command:name];
}

@end
