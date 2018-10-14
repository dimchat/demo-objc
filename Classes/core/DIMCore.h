//
//  DIMCore.h
//  DIM
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

//// Types
//#import "DIMDictionary.h"

// User
#import "DIMUser.h"
#import "DIMUser+History.h"
#import "DIMContact.h"

// Group
#import "DIMGroup.h"
#import "DIMMoments.h"

// Message
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"

//-
#import "DIMTransceiver.h"
#import "DIMConversation.h"

NS_ASSUME_NONNULL_BEGIN

#define DIM_CORE_VERSION 0x00010100

// free functions
NSString * dimCoreVersion(void);

NS_ASSUME_NONNULL_END
