//
//  DKDInstantMessage+Transform.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDInstantMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDSecureMessage;

@interface DKDInstantMessage (Transform)

- (DKDSecureMessage *)encrypt;

@end

NS_ASSUME_NONNULL_END
