//
//  DIMGroup.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMGroupWithID(ID)  (DIMGroup *)MKMGroupWithID(ID)

@class DIMInstantMessage;
@class DIMSecureMessage;

@interface DIMGroup : MKMGroup

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg;

// passphrase
- (MKMSymmetricKey *)cipherKeyForEncrypt:(const DIMInstantMessage *)msg;

@end

NS_ASSUME_NONNULL_END
