//
//  DIMInstantMessage.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMMessageContent;

/**
 *  Instant Message
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content
 *          content  : {...}
 *      }
 */
@interface DIMInstantMessage : DIMMessage

@property (readonly, strong, nonatomic) DIMMessageContent *content;

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(const NSDate *)time;

- (instancetype)initWithContent:(const DIMMessageContent *)content
                       envelope:(const DIMEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
