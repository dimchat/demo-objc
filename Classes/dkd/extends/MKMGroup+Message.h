//
//  MKMGroup+Message.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDInstantMessage;
@class DKDSecureMessage;

@class DKDEncryptedKeyMap;

@interface MKMGroup (Message)

- (DKDSecureMessage *)encryptMessage:(const DKDInstantMessage *)msg;

// passphrase
- (MKMSymmetricKey *)keyForEncryptMessage:(const DKDInstantMessage *)msg;
- (DKDEncryptedKeyMap *)secretKeysForKey:(const MKMSymmetricKey *)PW;

@end

NS_ASSUME_NONNULL_END
