//
//  MKMConsensus.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMConsensus : NSObject <MKMEntityHistoryDelegate>

@property (weak, nonatomic, nullable) id<MKMEntityHistoryDelegate> accountHistoryDelegate;
@property (weak, nonatomic, nullable) id<MKMEntityHistoryDelegate> groupHistoryDelegate;

+ (instancetype)sharedInstance;

@end

@class MKMHistory;
@class MKMHistoryRecord;

@interface MKMConsensus (History)

/**
 Run the whole history, stop when error
 
 @param history - history records
 @return Cout of success
 */
- (NSUInteger)runHistory:(const MKMHistory *)history forEntity:(MKMEntity *)entity;

/**
 Run one new history record
 
 @param record - history record
 @return YES when success
 */
- (BOOL)runHistoryRecord:(const MKMHistoryRecord *)record forEntity:(MKMEntity *)entity;

@end

NS_ASSUME_NONNULL_END
