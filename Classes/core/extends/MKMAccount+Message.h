//
//  MKMAccount+Message.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMInstantMessage;
@class DIMSecureMessage;
@class DIMReliableMessage;

@interface MKMAccount (Message)

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)iMsg;

- (DIMSecureMessage *)verifyMessage:(const DIMReliableMessage *)rMsg;

// passphrase
- (MKMSymmetricKey *)keyForEncryptMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
