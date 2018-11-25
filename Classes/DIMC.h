//
//  DIMC.h
//  DIMC
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

// MKM
//#import "MingKeMing.h"

// Core
//#import "DIMCore.h"

// CA
#import "DIMCASubject.h"
#import "DIMCAValidity.h"
#import "DIMCAData.h"
#import "DIMCertificateAuthority.h"

// Network
#import "DIMServiceProvider.h"
#import "DIMStation.h"

//-
#import "DIMConversation.h"
#import "DIMAmanuensis.h"
#import "DIMClient.h"
//#import "DIMImmortals.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMC_VERSION 0x00000100

// free functions
NSString * dimcVersion(void);

NS_ASSUME_NONNULL_END
