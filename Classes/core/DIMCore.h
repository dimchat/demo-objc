//
//  DIMCore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

// MKM
//#import "MingKeMing.h"

// Extends
#import "MKMAccount+Message.h"
#import "MKMUser+Message.h"
#import "MKMGroup+Message.h"

// Types
//#import "DIMDictionary.h"

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
#import "DIMKeyStore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIM_CORE_VERSION 0x00010100

// free functions
NSString * dimCoreVersion(void);

NS_ASSUME_NONNULL_END
