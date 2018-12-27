//
//  MingKeMing.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MingKeMing.
FOUNDATION_EXPORT double MingKeMingVersionNumber;

//! Project version string for MingKeMing.
FOUNDATION_EXPORT const unsigned char MingKeMingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MingKeMing/PublicHeader.h>

#if !defined(__MING_KE_MING__)
#define __MING_KE_MING__ 1

// Extends
//#import "NSObject+Singleton.h"
//#import "NSObject+JsON.h"
//#import "NSData+Crypto.h"
//#import "NSString+Crypto.h"
//#import "NSArray+Merkle.h"
//#import "NSDictionary+Binary.h"
//#import "NSDate+Timestamp.h"

// Types
//#import "MKMString.h"
//#import "MKMDictionary.h"

// Cryptography
//#import "MKMCryptographyKey.h"
//-- Symmetric
#import "MKMSymmetricKey.h"
//---- AES
//#import "MKMAESKey.h"
//-- Asymmetric
//#import "MKMAsymmetricKey.h"
#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"
//---- RSA
//#import "MKMRSAKeyHelper.h"
//#import "MKMRSAPublicKey.h"
//#import "MKMRSAPrivateKey.h"
//#import "MKMRSAPrivateKey+PersistentStore.h"
//---- ECC
//#import "MKMECCPublicKey.h"
//#import "MKMECCPrivateKey.h"

// Entity
#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMEntity.h"

// History
#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"
#import "MKMEntityHistoryDelegate.h"
#import "MKMAccountHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"
#import "MKMChatroomHistoryDelegate.h"
#import "MKMConsensus.h"
#import "MKMUser+History.h"

// Group
#import "MKMMember.h"
#import "MKMGroup.h"
#import "MKMPolylogue.h"
#import "MKMChatroom.h"

//-
#import "MKMAccount.h"
#import "MKMUser.h"
#import "MKMContact.h"

#import "MKMProfile.h"
#import "MKMBarrack.h"
#import "MKMBarrack+LocalStorage.h"
//#import "MKMImmortals.h"

#endif /* ! __MING_KE_MING__ */
