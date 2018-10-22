//
//  DIMCore.h
//  DIM
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

//// Types
//#import "DIMDictionary.h"

// Delegates
#import "DIMConnectionDelegate.h"
#import "DIMConversationDataSource.h"
#import "DIMConversationDelegate.h"

// User
#import "DIMUser.h"
#import "DIMUser+History.h"
#import "DIMContact.h"

// Group
#import "DIMGroup.h"

// Message
#import "DIMMessageContent.h"
#import "DIMMessageContent+Secret.h"
#import "DIMEnvelope.h"
#import "DIMMessage.h"
#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"

// System Command
#import "DIMCommandContent.h"
#import "DIMSystemCommand.h"

//-
#import "DIMTransceiver.h"
#import "DIMConversation.h"
#import "DIMKeyStore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIM_CORE_VERSION 0x00010100

// free functions
NSString * dimCoreVersion(void);

NS_ASSUME_NONNULL_END
