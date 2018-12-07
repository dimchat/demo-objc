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
#import "DIMEnvelope.h"
#import "DIMMessage.h"
#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMReliableMessage.h"

// Content
#import "DIMMessageContent.h"
#import "DIMMessageContent+Text.h"
#import "DIMMessageContent+File.h"
#import "DIMMessageContent+Image.h"
#import "DIMMessageContent+Audio.h"
#import "DIMMessageContent+Video.h"
#import "DIMMessageContent+Webpage.h"
#import "DIMMessageContent+Quote.h"
#import "DIMMessageContent+Command.h"
#import "DIMMessageContent+Forward.h"

//-
#import "DIMTransceiver.h"
#import "DIMKeyStore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIM_CORE_VERSION 0x00000100

// free functions
NSString * dimCoreVersion(void);

NS_ASSUME_NONNULL_END
