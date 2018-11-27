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

#pragma mark - System Command

// network
#define DIMSystemCommand_Handshake @"handshake"
#define DIMSystemCommand_Broadcast @"broadcast"

// message
#define DIMSystemCommand_Receipt   @"receipt"

// account
#define DIMSystemCommand_Register  @"register"
#define DIMSystemCommand_Suicide   @"suicide"

#pragma mark Group Command

// group: founder/owner
#define DIMGroupCommand_Found      @"found"
#define DIMGroupCommand_Abdicate   @"abdicate"
// group: member
#define DIMGroupCommand_Invite     @"invite"
#define DIMGroupCommand_Expel      @"expel"
#define DIMGroupCommand_Join       @"join"
#define DIMGroupCommand_Quit       @"quit"
// group: administrator/assistant
#define DIMGroupCommand_Hire       @"hire"
#define DIMGroupCommand_Fire       @"fire"
#define DIMGroupCommand_Resign     @"resign"

NS_ASSUME_NONNULL_END
