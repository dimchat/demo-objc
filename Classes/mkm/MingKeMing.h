//
//  MingKeMing.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

//// Extends
//#import "NSObject+JsON.h"
//#import "NSData+Crypto.h"
//#import "NSString+Crypto.h"
//#import "NSArray+Merkle.h"
//
//// Types
//#import "MKMString.h"
//#import "MKMArray.h"
//#import "MKMDictionary.h"

// Cryptography
#import "MKMCryptographyKey.h"
#import "MKMSymmetricKey.h"
#import "MKMAsymmetricKey.h"
#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"
#import "MKMKeyStore.h"
//#import "MKMAESKey.h"
//#import "MKMRSAPublicKey.h"
//#import "MKMRSAPrivateKey.h"
//#import "MKMECCPublicKey.h"
//#import "MKMECCPrivateKey.h"

// Delegates
#import "MKMEntityDelegate.h"
#import "MKMEntityHistoryDelegate.h"
#import "MKMSocialEntityHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"
#import "MKMAccountHistoryDelegate.h"
#import "MKMProfileDelegate.h"

// Entity
#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"
#import "MKMHistory.h"
#import "MKMEntity.h"
#import "MKMEntity+History.h"
#import "MKMEntityManager.h"

// group
#import "MKMSocialEntity.h"
#import "MKMGroup.h"
#import "MKMMoments.h"

// user
#import "MKMAccount.h"
#import "MKMUser.h"
#import "MKMContact.h"

// profile
#import "MKMProfile.h"
#import "MKMMemo.h"
#import "MKMFacebook.h"

NS_ASSUME_NONNULL_BEGIN

#define MKM_VERSION 0x00010100

// free functions
NSString * mkmVersion(void);

NS_ASSUME_NONNULL_END
