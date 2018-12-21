//
//  MKMAccount+Message.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDInstantMessage;
@class DKDSecureMessage;
@class DKDReliableMessage;

@interface MKMAccount (Message)

- (DKDSecureMessage *)encryptMessage:(const DKDInstantMessage *)iMsg;

- (DKDSecureMessage *)verifyMessage:(const DKDReliableMessage *)rMsg;

// passphrase
- (MKMSymmetricKey *)keyForEncryptMessage:(const DKDInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
