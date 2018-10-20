//
//  DIMC.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

// MKM
//#import "MingKeMing.h"

// Core
//#import "DIMCore.h"

// Network
#import "DIMCertificateAuthority.h"
#import "DIMServiceProvider.h"
#import "DIMStation.h"
#import "DIMConnection.h"

//-
#import "DIMBarrack.h"
#import "DIMClient.h"
#import "DIMClient+Message.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMC_VERSION 0x00010100

// free functions
NSString * dimcVersion(void);

NS_ASSUME_NONNULL_END
