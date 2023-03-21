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

#import <DIMP/NSObject+Compare.h>
#import <DIMP/NSObject+Threading.h>
#import <DIMP/NSDate+Extension.h>
#import <DIMP/NSDictionary+Binary.h>

//
//  Common
//

#import <DIMP/DIMFrequencyChecker.h>
#import <DIMP/DIMQueryFrequencyChecker.h>

#import <DIMP/DIMAccountDBI.h>
#import <DIMP/DIMMessageDBI.h>
#import <DIMP/DIMSessionDBI.h>

#import <DIMP/DIMAnsCommand.h>
#import <DIMP/DIMHandshakeCommand.h>
#import <DIMP/DIMLoginCommand.h>
#import <DIMP/DIMReceiptCommand.h>
#import <DIMP/DIMReportCommand.h>
#import <DIMP/DIMMuteCommand.h>
#import <DIMP/DIMBlockCommand.h>

#import <DIMP/DIMRegister.h>
#import <DIMP/DIMAddressNameServer.h>
#import <DIMP/DIMCommonFacebook.h>
#import <DIMP/DIMSession.h>
#import <DIMP/DIMCommonMessenger.h>

//
//  Database
//

#import <DIMP/DIMStorage.h>

//
//  StarGate
//

#import <DIMP/STCommonGate.h>
#import <DIMP/STStreamChannel.h>
#import <DIMP/STStreamHub.h>
#import <DIMP/STStreamArrival.h>
#import <DIMP/STStreamDeparture.h>
#import <DIMP/STStreamDocker.h>

//
//  Network
//

#import <DIMP/DIMWrapperQueue.h>
#import <DIMP/DIMGateKeeper.h>
#import <DIMP/DIMBaseSession.h>
#import <DIMP/DIMFileTask.h>
#import <DIMP/DIMHttpClient.h>
#import <DIMP/DIMUploadTask.h>
#import <DIMP/DIMDownloadTask.h>

//
//  Client
//

#import <DIMP/DIMInviteCommandProcessor.h>
#import <DIMP/DIMExpelCommandProcessor.h>
#import <DIMP/DIMQuitCommandProcessor.h>
#import <DIMP/DIMQueryCommandProcessor.h>
#import <DIMP/DIMResetCommandProcessor.h>

#import <DIMP/DIMGroupCommandProcessor.h>
#import <DIMP/DIMHistoryProcessor.h>
#import <DIMP/DIMCreator.h>
#import <DIMP/DIMHandshakeCommandProcessor.h>
#import <DIMP/DIMLoginCommandProcessor.h>
#import <DIMP/DIMReceiptCommandProcessor.h>
#import <DIMP/DIMAnsCommandProcessor.h>

#import <DIMP/DIMClientSession.h>
#import <DIMP/DIMClientSession+State.h>
#import <DIMP/DIMClientMessagePacker.h>
#import <DIMP/DIMClientMessageProcessor.h>
#import <DIMP/DIMClientMessenger.h>
#import <DIMP/DIMClientFacebook.h>


#import <DIMP/MKMAnonymous.h>
#import <DIMP/DIMGroupManager.h>
#import <DIMP/DIMTerminal.h>

#endif /* ! __DIM_CLIENT__ */
