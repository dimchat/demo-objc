//
//  MKMHistory.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;

@class MKMHistoryBlock;

/**
 *  history
 *
 *      data format: {
 *          ID: "name@address", // entity ID
 *          records: [],        // history blocks
 *      }
 */
@interface MKMHistory : MKMDictionary

@property (readonly, strong, nonatomic) MKMID *ID;

@property (readonly, strong, nonatomic) NSArray *blocks; // records

+ (instancetype)historyWithHistory:(id)history;

- (instancetype)initWithID:(const MKMID *)ID;

- (void)addBlock:(MKMHistoryBlock *)record;

@end

NS_ASSUME_NONNULL_END
