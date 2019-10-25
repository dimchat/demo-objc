//
//  DIMBlockCommand.h
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Block   @"block"

@interface DIMBlockCommand : DIMHistoryCommand

// timestamp which already defined in HistoryCommand
//@property (readonly, strong, nonatomic) NSDate *time;

// block-list
@property (strong, nonatomic, nullable) NSArray<DIMID *> *list;

/**
 *  BlockCommand message: {
 *      type : 0x89,
 *
 *      command : "block",
 *      time    : 0,     // timestamp
 *      list    : [] // block-list; if it's None, means querying block-list from station
 *  }
 */
- (instancetype)initWithList:(nullable NSArray<DIMID *> *)blockList;

- (void)addID:(DIMID *)ID;
- (void)removeID:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
