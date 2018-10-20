//
//  DIMSystemCommand.h
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMCommandContent;

/**
 *  System Command
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- command
 *          command  : {...}
 *      }
 */
@interface DIMSystemCommand : DIMMessage

@property (readonly, strong, nonatomic) DIMCommandContent *command;

- (instancetype)initWithCommand:(const DIMCommandContent *)command
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(const NSDate *)time;

- (instancetype)initWithCommand:(const DIMCommandContent *)command
                       envelope:(const DIMEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
