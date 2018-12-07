//
//  DIMMessageContent+Forward.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMReliableMessage;

@interface DIMMessageContent (TopSecret)

// Top-Secret message forwarded by a proxy (Service Provider)
@property (readonly, nonatomic) DIMReliableMessage *forwardMessage;

/**
 *  Top-Secret message: {
 *      type : 0xFF,
 *      sn   : 456,
 *
 *      forward : {...}  // reliable (secure + certified) message
 *  }
 */
- (instancetype)initWithForwardMessage:(const DIMReliableMessage *)rMsg;

@end

NS_ASSUME_NONNULL_END
