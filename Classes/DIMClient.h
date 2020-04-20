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
//  DIMClient.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DIMClient.
FOUNDATION_EXPORT double DIMClientVersionNumber;

//! Project version string for DIMClient.
FOUNDATION_EXPORT const unsigned char DIMClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMClient/PublicHeader.h>

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
#import <DIMClient/MKMUser+Extension.h>
#import <DIMClient/MKMGroup+Extension.h>
#import <DIMClient/DIMFacebook+Extension.h>
#import <DIMClient/DIMMessenger+Extension.h>
#import <DIMClient/DIMCommand+Extension.h>
#import <DIMClient/DIMPassword.h>
#import <DIMClient/DIMRegister.h>
#import <DIMClient/DIMGroupManager.h>

// Command
#import <DIMClient/DIMSearchCommand.h>

// CPU
#import <DIMClient/DIMDefaultProcessor.h>
#import <DIMClient/DIMHandshakeCommandProcessor.h>
#import <DIMClient/DIMReceiptCommandProcessor.h>
#import <DIMClient/DIMSearchCommandProcessor.h>
#import <DIMClient/DIMMuteCommandProcessor.h>
#import <DIMClient/DIMStorageCommandProcessor.h>

// Database
#import <DIMClient/DIMClientConstants.h>
#import <DIMClient/DIMStorage.h>
#import <DIMClient/DIMAddressNameTable.h>
#import <DIMClient/DIMMetaTable.h>
#import <DIMClient/DIMProfileTable.h>
#import <DIMClient/DIMUserTable.h>
#import <DIMClient/DIMGroupTable.h>
#import <DIMClient/DIMMessageTable.h>
#import <DIMClient/DIMSocialNetworkDatabase.h>
#import <DIMClient/DIMConversationDatabase.h>

#import <DIMClient/DIMFileServer.h>
#import <DIMClient/DIMServer.h>
#import <DIMClient/DIMServerState.h>

#import <DIMClient/DIMConversation.h>
#import <DIMClient/DIMAmanuensis.h>

#import <DIMClient/DIMTerminal.h>
#import <DIMClient/DIMTerminal+Group.h>

#endif /* ! __DIM_CLIENT__ */
