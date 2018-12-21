//
//  MKMUser+Message.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDInstantMessage;
@class DKDSecureMessage;
@class DKDReliableMessage;

@interface MKMUser (Message)

- (DKDInstantMessage *)decryptMessage:(const DKDSecureMessage *)sMsg;

- (DKDReliableMessage *)signMessage:(const DKDSecureMessage *)sMsg;

// passphrase
- (MKMSymmetricKey *)keyForDecrpytMessage:(const DKDSecureMessage *)sMsg;

@end

NS_ASSUME_NONNULL_END
