//
//  DKDInstantMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDMessageContent;

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
@interface DKDInstantMessage : DKDMessage

@property (readonly, strong, nonatomic) DKDMessageContent *content;

- (instancetype)initWithContent:(const DKDMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(nullable const NSDate *)time;

- (instancetype)initWithContent:(const DKDMessageContent *)content
                       envelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
