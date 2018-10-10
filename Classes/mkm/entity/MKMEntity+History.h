//
//  MKMEntity+History.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMEntity (History)

/**
 Run the whole history, stop when error
 
 @param history - history records
 @return Cout of success
 */
- (NSUInteger)runHistory:(const MKMHistory *)history;

/**
 Run one new history record
 
 @param record - history record
 @return YES when success
 */
- (BOOL)runHistoryRecord:(const MKMHistoryRecord *)record;

@end

NS_ASSUME_NONNULL_END
