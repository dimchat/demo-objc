//
//  DIMMessageContent+Text.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent (Text)

@property (readonly, strong, nonatomic) NSString *text;

/**
 *  Text message: {
 *      type : 0x01,
 *      sn   : 123,
 *
 *      text : "..."
 *  }
 */
- (instancetype)initWithText:(const NSString *)text;

@end

NS_ASSUME_NONNULL_END
