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
//  DIMP.h
//  DIMP
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DIMP.
FOUNDATION_EXPORT double DIMPVersionNumber;

//! Project version string for DIMP.
FOUNDATION_EXPORT const unsigned char DIMPVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMP/PublicHeader.h>

// MKM
//#import <MingKeMing/MingKeMing.h>

// DKD
//#import <DaoKeDao/DaoKeDao.h>

// Core
//#import <DIMCore/DIMCore.h>

// SDK
//#import <DIMSDK/DIMSDK.h>

// FiniteStateMachine
//#import <FiniteStateMachine/FiniteStateMachine.h>

// StarGate
//#import <MarsGate/MarsGate.h>

#if !defined(__DIM_CLIENT__)
#define __DIM_CLIENT__ 1

// Extensions
#import <DIMP/DKDInstantMessage+Extension.h>
#import <DIMP/DIMEntity+Extension.h>
#import <DIMP/DIMFacebook+Extension.h>
#import <DIMP/DIMMessageProcessor+Extension.h>
#import <DIMP/DIMMessenger+Extension.h>
#import <DIMP/DIMCommand+Extension.h>
#import <DIMP/DIMPassword.h>
#import <DIMP/DIMRegister.h>
#import <DIMP/DIMGroupManager.h>

// Command
#import <DIMP/DIMReceiptCommand.h>
#import <DIMP/DIMHandshakeCommand.h>
#import <DIMP/DIMLoginCommand.h>
#import <DIMP/DIMBlockCommand.h>
#import <DIMP/DIMMuteCommand.h>
#import <DIMP/DIMStorageCommand.h>
#import <DIMP/DIMSearchCommand.h>
#import <DIMP/DIMReportCommand.h>

// CPU
#import <DIMP/DIMDefaultProcessor.h>
#import <DIMP/DIMApplicationContentProcessor.h>
#import <DIMP/DIMFileContentProcessor.h>
#import <DIMP/DIMReceiptCommandProcessor.h>
#import <DIMP/DIMHandshakeCommandProcessor.h>
#import <DIMP/DIMLoginCommandProcessor.h>
#import <DIMP/DIMSearchCommandProcessor.h>
#import <DIMP/DIMMuteCommandProcessor.h>
#import <DIMP/DIMStorageCommandProcessor.h>
#import <DIMP/DIMHistoryProcessor.h>
// GPUs
#import <DIMP/DIMGroupCommandProcessor.h>
#import <DIMP/DIMInviteCommandProcessor.h>
#import <DIMP/DIMExpelCommandProcessor.h>
#import <DIMP/DIMQuitCommandProcessor.h>
#import <DIMP/DIMResetCommandProcessor.h>
#import <DIMP/DIMQueryCommandProcessor.h>

// Database
#import <DIMP/DIMPConstants.h>
#import <DIMP/DIMStorage.h>
#import <DIMP/DIMAddressNameTable.h>
#import <DIMP/DIMMetaTable.h>
#import <DIMP/DIMProfileTable.h>
#import <DIMP/DIMUserTable.h>
#import <DIMP/DIMGroupTable.h>
#import <DIMP/DIMMessageTable.h>
#import <DIMP/DIMSocialNetworkDatabase.h>
#import <DIMP/DIMConversationDatabase.h>

#import <DIMP/DIMFileServer.h>
#import <DIMP/DIMServer.h>
#import <DIMP/DIMServerState.h>

#import <DIMP/DIMConversation.h>
#import <DIMP/DIMAmanuensis.h>

#import <DIMP/DIMTerminal.h>

#endif /* ! __DIM_CLIENT__ */
