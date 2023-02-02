// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DIMMessageProcessor+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/23.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"
#import "DIMLoginCommand.h"
#import "DIMReceiptCommand.h"
#import "DIMMuteCommand.h"
#import "DIMBlockCommand.h"
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

#import "DIMMessageProcessor+Extension.h"

@implementation DIMMessageProcessor (Plugins)

+ (void)loadPlugins {
    //
    //  Register common factories
    //
    [self registerAllFactories];
    
    //
    //  Register command factories
    //
    DIMCommandRegisterClass(DIMCommand_Receipt, DIMReceiptCommand);
    DIMCommandRegisterClass(DIMCommand_Handshake, DIMHandshakeCommand);
    DIMCommandRegisterClass(DIMCommand_Login, DIMLoginCommand);
    
    DIMCommandRegisterClass(DIMCommand_Mute, DIMMuteCommand);
    DIMCommandRegisterClass(DIMCommand_Block, DIMBlockCommand);
    
    // storage (contacts, private_key)
    DIMCommandRegisterClass(DIMCommand_Storage, DIMStorageCommand);
    DIMCommandRegisterClass(DIMCommand_Contacts, DIMStorageCommand);
    DIMCommandRegisterClass(DIMCommand_PrivateKey, DIMStorageCommand);

    DIMCommandRegisterClass(DIMCommand_Search, DIMSearchCommand);
    DIMCommandRegisterClass(DIMCommand_OnlineUsers, DIMSearchCommand);
    
    DIMCommandRegisterClass(DIMCommand_Report, DIMReportCommand);
    DIMCommandRegisterClass(DIMCommand_Online, DIMReportCommand);
    DIMCommandRegisterClass(DIMCommand_Offline, DIMReportCommand);
}

@end
