//
//  MingKeMing.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

// Extends
#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"
#import "NSData+Asymmetric.h"

//// Types
//#import "MKMString.h"
//#import "MKMArray.h"
//#import "MKMDictionary.h"

// Cryptography
#import "MKMAsymmetricKey.h"
#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"
#import "MKMKeyStore.h"

//#import "MKMRSAPublicKey.h"
//#import "MKMRSAPrivateKey.h"
//#import "MKMECCPublicKey.h"
//#import "MKMECCPrivateKey.h"

// Entity
#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"
#import "MKMEntity.h"

// User
#import "MKMProfile.h"
#import "MKMAccount.h"
#import "MKMUser.h"
#import "MKMContact.h"

// Group
#import "MKMSocialEntity.h"
#import "MKMGroup.h"
#import "MKMMoments.h"

NS_ASSUME_NONNULL_BEGIN

#define MKM_VERSION 0x00010100

// free functions
NSString * mkmVersion(void);

NS_ASSUME_NONNULL_END
