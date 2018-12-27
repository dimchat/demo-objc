//
//  DKDSecureMessage+Transform.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDSecureMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDInstantMessage;
@class DKDReliableMessage;

@interface DKDSecureMessage (Transform)

- (DKDInstantMessage *)decrypt;

- (DKDReliableMessage *)sign;

@end

NS_ASSUME_NONNULL_END
