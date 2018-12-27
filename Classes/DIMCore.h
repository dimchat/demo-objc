//
//  DIMCore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DIMCore.
FOUNDATION_EXPORT double DIMCoreVersionNumber;

//! Project version string for DIMCore.
FOUNDATION_EXPORT const unsigned char DIMCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMCore/PublicHeader.h>

// MKM
//#import "MingKeMing.h"

// DKD
//#import "DaoKeDao.h"

#if !defined(__DIM_CORE__)
#define __DIM_CORE__ 1

#import "dimMacros.h"

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

#endif /* ! __DIM_CORE__ */
