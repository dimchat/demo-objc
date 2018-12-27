//
//  DKDReliableMessage+Meta.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extends for the first message package of 'Handshake' protocol
 */
@interface DKDReliableMessage (Meta)

@property (strong, nonatomic) MKMMeta *meta;

@end

NS_ASSUME_NONNULL_END
