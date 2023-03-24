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
//  DIMCreator.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"
#import "DIMLoginCommand.h"
#import "DIMReceiptCommand.h"
//#import "DIMReportCommand.h"
//#import "DIMMuteCommand.h"
//#import "DIMBlockCommand.h"
#import "DIMAnsCommand.h"

#import "DIMHistoryProcessor.h"
#import "DIMGroupCommandProcessor.h"
#import "DIMInviteCommandProcessor.h"
#import "DIMExpelCommandProcessor.h"
#import "DIMQuitCommandProcessor.h"
#import "DIMQueryCommandProcessor.h"
#import "DIMResetCommandProcessor.h"

#import "DIMHandshakeCommandProcessor.h"
#import "DIMLoginCommandProcessor.h"
#import "DIMReceiptCommandProcessor.h"
#import "DIMAnsCommandProcessor.h"

#import "DIMCreator.h"

#define CREATE_CPU(clazz)                                                      \
            [[clazz alloc] initWithFacebook:self.facebook                      \
                                  messenger:self.messenger]                    \
                                                   /* EOF 'CREATE_CPU(clazz)' */

@implementation DIMClientContentProcessorCreator

- (id<DIMContentProcessor>)createContentProcessor:(DKDContentType)type {
    // history command
    if (type == DKDContentType_History) {
        return CREATE_CPU(DIMHistoryCommandProcessor);
    }
    // default
    if (type == 0) {
        return CREATE_CPU(DIMContentProcessor);
    }
    // others
    return [super createContentProcessor:type];
}

- (id<DIMContentProcessor>)createCommandProcessor:(NSString *)name type:(DKDContentType)msgType {
    // handshake
    if ([name isEqualToString:DIMCommand_Handshake]) {
        return CREATE_CPU(DIMHandshakeCommandProcessor);
    }
    // login
    if ([name isEqualToString:DIMCommand_Login]) {
        return CREATE_CPU(DIMLoginCommandProcessor);
    }
    // receipt
    if ([name isEqualToString:DIMCommand_Receipt]) {
        return CREATE_CPU(DIMReceiptCommandProcessor);
    }
    // ans
    if ([name isEqualToString:DIMCommand_ANS]) {
        return CREATE_CPU(DIMAnsCommandProcessor);
    }

    // group commands
    if ([name isEqualToString:@"group"]) {
        return CREATE_CPU(DIMGroupCommandProcessor);
    } else if ([name isEqualToString:DIMGroupCommand_Invite]) {
        return CREATE_CPU(DIMInviteGroupCommandProcessor);
    } else if ([name isEqualToString:DIMGroupCommand_Expel]) {
        return CREATE_CPU(DIMExpelGroupCommandProcessor);
    } else if ([name isEqualToString:DIMGroupCommand_Quit]) {
        return CREATE_CPU(DIMQuitGroupCommandProcessor);
    } else if ([name isEqualToString:DIMGroupCommand_Query]) {
        return CREATE_CPU(DIMQueryGroupCommandProcessor);
    } else if ([name isEqualToString:DIMGroupCommand_Reset]) {
        return CREATE_CPU(DIMResetGroupCommandProcessor);
    }
    // others
    return [super createCommandProcessor:name type:msgType];
}

@end
