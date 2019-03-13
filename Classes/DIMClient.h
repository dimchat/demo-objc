//
//  DIMClient.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DIMClient.
FOUNDATION_EXPORT double DIMClientVersionNumber;

//! Project version string for DIMClient.
FOUNDATION_EXPORT const unsigned char DIMClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMClient/PublicHeader.h>

// MKM
//#import <MingKeMing/MingKeMing.h>

// DKD
//#import <DaoKeDao/DaoKeDao.h>

// Core
//#import <DIMCore/DIMCore.h>

// StarGate
//#import <MarsGate/MarsGate.h>

#if !defined(__DIM_CLIENT__)
#define __DIM_CLIENT__ 1

// extends
//#import <DIMClient/NSString+Extension.h>
//#import <DIMClient/NSNotificationCenter+Extension.h>
//#import <DIMClient/UIImage+Extension.h>
//#import <DIMClient/UIImageView+Extension.h>
//#import <DIMClient/UIViewController+Extension.h>
//#import <DIMClient/UIStoryboardSegue+Extension.h>
#import <DIMClient/DIMProfile+Extension.h>

#import <DIMClient/DIMServer.h>
#import <DIMClient/DIMServerState.h>

#import <DIMClient/DIMTerminal.h>
#import <DIMClient/DIMTerminal+Request.h>
#import <DIMClient/DIMTerminal+Response.h>
#import <DIMClient/DIMTerminal+Group.h>

#endif /* ! __DIM_CLIENT__ */
