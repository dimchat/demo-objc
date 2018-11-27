//
//  DIMMessageContent+Command.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent (Command)

@property (readonly, strong, nonatomic) NSString *command;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
- (instancetype)initWithCommand:(const NSString *)cmd;

@end

NS_ASSUME_NONNULL_END
