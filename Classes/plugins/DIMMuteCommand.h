//
//  DIMMuteCommand.h
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Mute   @"mute"

@interface DIMMuteCommand : DIMHistoryCommand

// timestamp which already defined in HistoryCommand
//@property (readonly, strong, nonatomic) NSDate *time;

// mute-list
@property (strong, nonatomic, nullable) NSArray<DIMID *> *list;

/**
 *  MuteCommand message: {
 *      type : 0x89,
 *
 *      command : "mute",
 *      time    : 0,     // timestamp
 *      list    : [] // mute-list; if it's None, means querying mute-list from station
 *  }
 */
- (instancetype)initWithList:(nullable NSArray<DIMID *> *)muteList;

- (void)addID:(DIMID *)ID;
- (void)removeID:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
