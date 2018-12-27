//
//  DKDReliableMessage+Transform.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDSecureMessage;

@interface DKDReliableMessage (Transform)

- (DKDSecureMessage *)verify;

@end

NS_ASSUME_NONNULL_END
