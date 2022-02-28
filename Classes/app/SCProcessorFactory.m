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

#define CREATE_CPU(clazz)                                                      \
            [[clazz alloc] initWithFacebook:self.facebook                      \
                                  messenger:self.messenger]                    \
                                                   /* EOF 'CREATE_CPU(clazz)' */

@implementation SCProcessorFactory

- (DIMContentProcessor *)createProcessorWithType:(DKDContentType)type {
    // file
    if (type == DKDContentType_File) {
        return CREATE_CPU(DIMFileContentProcessor);
    } else if (type == DKDContentType_Image || type == DKDContentType_Audio || type == DKDContentType_Video) {
        // TODO: shared the same processor with 'FILE'?
        return CREATE_CPU(DIMFileContentProcessor);
    }
    DIMContentProcessor *cpu = [super createProcessorWithType:type];
    if (!cpu) {
        // unknown
        return CREATE_CPU(DIMDefaultContentProcessor);
    }
    return cpu;
}

- (DIMCommandProcessor *)createProcessorWithName:(NSString *)name
                                            type:(DKDContentType)type {
    // receipt
    if ([name isEqualToString:DIMCommand_Receipt]) {
        return CREATE_CPU(DIMReceiptCommandProcessor);
    }
    // mute
    if ([name isEqualToString:DIMCommand_Mute]) {
        return CREATE_CPU(DIMMuteCommandProcessor);
    }
    // block
    if ([name isEqualToString:DIMCommand_Block]) {
        return CREATE_CPU(DIMBlockCommandProcessor);
    }
    // handshake
    if ([name isEqualToString:DIMCommand_Handshake]) {
        return CREATE_CPU(DIMHandshakeCommandProcessor);
    }
    // login
    if ([name isEqualToString:DIMCommand_Login]) {
        return CREATE_CPU(DIMLoginCommandProcessor);
    }
    // storage
    if ([name isEqualToString:DIMCommand_Storage]) {
        return CREATE_CPU(DIMStorageCommandProcessor);
    } else if ([name isEqualToString:@"contacts"] || [name isEqualToString:@"private_key"]) {
        // TODO: shared the same processor with 'storage'?
        return CREATE_CPU(DIMStorageCommandProcessor);
    }
    // search
    if ([name isEqualToString:DIMCommand_Search]) {
        return CREATE_CPU(DIMSearchCommandProcessor);
    } else if ([name isEqualToString:DIMCommand_OnlineUsers]) {
        // TODO: shared the same processor with 'search'?
        return CREATE_CPU(DIMSearchCommandProcessor);
    }
    // others
    return [super createProcessorWithName:name type:type];
}

@end
