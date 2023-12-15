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

//! Project version number for DIMPClient.
FOUNDATION_EXPORT double DIMPClientVersionNumber;

//! Project version string for DIMPClient.
FOUNDATION_EXPORT const unsigned char DIMPClientVersionString[];

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


//
//  Extensions
//

#import <DIMClient/NSObject+Compare.h>
#import <DIMClient/NSObject+Threading.h>
#import <DIMClient/NSDate+Extension.h>
#import <DIMClient/NSDictionary+Binary.h>

//
//  Common
//

#import <DIMClient/DIMNetworkID.h>
#import <DIMClient/DIMAddressBTC.h>
#import <DIMClient/DIMEntityID.h>
#import <DIMClient/DIMMetaC.h>
#import <DIMClient/DIMCompatible.h>

#import <DIMClient/DIMAccountDBI.h>
#import <DIMClient/DIMMessageDBI.h>
#import <DIMClient/DIMSessionDBI.h>

#import <DIMClient/DIMAnsCommand.h>
#import <DIMClient/DIMHandshakeCommand.h>
#import <DIMClient/DIMLoginCommand.h>
#import <DIMClient/DIMReportCommand.h>
#import <DIMClient/DIMMuteCommand.h>
#import <DIMClient/DIMBlockCommand.h>

#import <DIMClient/MKMAnonymous.h>
#import <DIMClient/DIMRegister.h>
#import <DIMClient/DIMAddressNameServer.h>
#import <DIMClient/DIMCommonArchivist.h>
#import <DIMClient/DIMCommonFacebook.h>
#import <DIMClient/DIMSession.h>
#import <DIMClient/DIMCommonPacker.h>
#import <DIMClient/DIMCommonMessenger.h>

//
//  Database
//

#import <DIMClient/DIMStorage.h>

//
//  StarGate
//

#import <DIMClient/STCommonGate.h>
#import <DIMClient/STStreamChannel.h>
#import <DIMClient/STStreamHub.h>
#import <DIMClient/STStreamArrival.h>
#import <DIMClient/STStreamDeparture.h>
#import <DIMClient/STStreamDocker.h>

//
//  Network
//

#import <DIMClient/DIMWrapperQueue.h>
#import <DIMClient/DIMGateKeeper.h>
#import <DIMClient/DIMBaseSession.h>
#import <DIMClient/DIMFileTask.h>
#import <DIMClient/DIMHttpClient.h>
#import <DIMClient/DIMUploadTask.h>
#import <DIMClient/DIMDownloadTask.h>

//
//  Group
//

#import <DIMClient/DIMGroupDelegate.h>
#import <DIMClient/DIMGroupCommandHelper.h>
#import <DIMClient/DIMGroupHistoryBuilder.h>
#import <DIMClient/DIMGroupPacker.h>
#import <DIMClient/DIMGroupEmitter.h>
#import <DIMClient/DIMGroupManager.h>
#import <DIMClient/DIMGroupAdminManager.h>

//
//  Client
//

#import <DIMClient/DIMInviteCommandProcessor.h>
#import <DIMClient/DIMExpelCommandProcessor.h>
#import <DIMClient/DIMQuitCommandProcessor.h>
#import <DIMClient/DIMQueryCommandProcessor.h>
#import <DIMClient/DIMResetCommandProcessor.h>

#import <DIMClient/DIMGroupCommandProcessor.h>
#import <DIMClient/DIMHistoryProcessor.h>
#import <DIMClient/DIMCreator.h>
#import <DIMClient/DIMHandshakeCommandProcessor.h>
#import <DIMClient/DIMLoginCommandProcessor.h>
#import <DIMClient/DIMReceiptCommandProcessor.h>
#import <DIMClient/DIMAnsCommandProcessor.h>

#import <DIMClient/DIMClientSession.h>
#import <DIMClient/DIMClientSession+State.h>
#import <DIMClient/DIMClientMessagePacker.h>
#import <DIMClient/DIMClientMessageProcessor.h>
#import <DIMClient/DIMClientMessenger.h>
#import <DIMClient/DIMClientArchivist.h>
#import <DIMClient/DIMClientFacebook.h>
#import <DIMClient/DIMTerminal.h>

#endif /* ! __DIM_CLIENT__ */
