//
//  MKMUser+Message.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMInstantMessage;
@class DIMSecureMessage;
@class DIMReliableMessage;

@interface MKMUser (Message)

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)sMsg;

- (DIMReliableMessage *)signMessage:(const DIMSecureMessage *)sMsg;

// passphrase
- (MKMSymmetricKey *)keyForDecrpytMessage:(const DIMSecureMessage *)sMsg;

@end

NS_ASSUME_NONNULL_END
