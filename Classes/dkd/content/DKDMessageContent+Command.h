//
//  DKDMessageContent+Command.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDMessageContent (Command)

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
#define DKDSystemCommand_Handshake @"handshake"
#define DKDSystemCommand_Broadcast @"broadcast"

// message
#define DKDSystemCommand_Receipt   @"receipt"

// account
#define DKDSystemCommand_Register  @"register"
#define DKDSystemCommand_Suicide   @"suicide"

#pragma mark Group Command

// group: founder/owner
#define DKDGroupCommand_Found      @"found"
#define DKDGroupCommand_Abdicate   @"abdicate"
// group: member
#define DKDGroupCommand_Invite     @"invite"
#define DKDGroupCommand_Expel      @"expel"
#define DKDGroupCommand_Join       @"join"
#define DKDGroupCommand_Quit       @"quit"
// group: administrator/assistant
#define DKDGroupCommand_Hire       @"hire"
#define DKDGroupCommand_Fire       @"fire"
#define DKDGroupCommand_Resign     @"resign"

NS_ASSUME_NONNULL_END
