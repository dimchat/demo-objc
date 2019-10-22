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

// FiniteStateMachine
//#import <FiniteStateMachine/FiniteStateMachine.h>

// StarGate
//#import <MarsGate/MarsGate.h>

// MKM
//#import <MingKeMing/MingKeMing.h>

// DKD
//#import <DaoKeDao/DaoKeDao.h>

// Core
//#import <DIMCore/DIMCore.h>

#if !defined(__DIM_CLIENT__)
#define __DIM_CLIENT__ 1

// Extensions
#import <DIMClient/MKMUser+Extension.h>
#import <DIMClient/MKMGroup+Extension.h>
#import <DIMClient/DKDInstantMessage+Extension.h>
#import <DIMClient/DIMPassword.h>

// Plug-Ins
#import <DIMClient/DIMReceiptCommand.h>

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

#import <DIMClient/DIMFacebook.h>
#import <DIMClient/DIMKeyStore.h>
#import <DIMClient/DIMMessenger.h>

#import <DIMClient/DIMFileServer.h>
#import <DIMClient/DIMServer.h>
#import <DIMClient/DIMServerState.h>

#import <DIMClient/DIMConversation.h>
#import <DIMClient/DIMAmanuensis.h>

#import <DIMClient/DIMTerminal.h>
#import <DIMClient/DIMTerminal+Request.h>
#import <DIMClient/DIMTerminal+Response.h>
#import <DIMClient/DIMTerminal+Group.h>

#endif /* ! __DIM_CLIENT__ */
