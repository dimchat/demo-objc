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

#import "DIMSearchCommand.h"
#import "DIMReportCommand.h"

#import "DIMDefaultProcessor.h"

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
    //  load content/command factories
    //
    [DIMMessageProcessor registerAllFactories];
    
    DIMCommandFactoryRegisterClass(DIMCommand_Search, DIMSearchCommand);
    DIMCommandFactoryRegisterClass(DIMCommand_OnlineUsers, DIMSearchCommand);
    
    DIMCommandFactoryRegisterClass(DIMCommand_Report, DIMReportCommand);
    DIMCommandFactoryRegisterClass(DIMCommand_Online, DIMReportCommand);
    DIMCommandFactoryRegisterClass(DIMCommand_Offline, DIMReportCommand);

    //
    //  load content/command processors
    //
    [DIMMessageProcessor registerAllProcessors];
    
    DIMContentProcessorRegisterClass(DKDContentType_Unknown, DIMDefaultContentProcessor);
    
    DIMCommandProcessorRegisterClass(DIMCommand_Receipt, DIMReceiptCommandProcessor);
    DIMCommandProcessorRegisterClass(DIMCommand_Mute, DIMMuteCommandProcessor);
    DIMCommandProcessorRegisterClass(DIMCommand_Block, DIMBlockCommandProcessor);

    DIMCommandProcessorRegisterClass(DIMCommand_Handshake, DIMHandshakeCommandProcessor);
    DIMCommandProcessorRegisterClass(DIMCommand_Login, DIMLoginCommandProcessor);
    
    DIMStorageCommandProcessor *storeProcessor = [[DIMStorageCommandProcessor alloc] init];
    DIMCommandProcessorRegister(DIMCommand_Storage, storeProcessor);
    DIMCommandProcessorRegister(DIMCommand_Contacts, storeProcessor);
    DIMCommandProcessorRegister(DIMCommand_PrivateKey, storeProcessor);
    
    DIMSearchCommandProcessor *searchProcessor = [[DIMSearchCommandProcessor alloc] init];
    DIMCommandProcessorRegister(DIMCommand_Search, searchProcessor);
    DIMCommandProcessorRegister(DIMCommand_OnlineUsers, searchProcessor);
}

@end
