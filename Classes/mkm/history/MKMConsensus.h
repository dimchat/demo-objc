//
//  MKMConsensus.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMHistoryForID(ID) [[MKMConsensus sharedInstance] historyForEntityID:(ID)]

@interface MKMConsensus : NSObject <MKMEntityHistoryDelegate, MKMEntityHistoryDataSource>

@property (weak, nonatomic) id<MKMEntityHistoryDelegate> accountHistoryDelegate;
@property (weak, nonatomic) id<MKMEntityHistoryDelegate> groupHistoryDelegate;

@property (weak, nonatomic) id<MKMEntityHistoryDataSource> entityHistoryDataSource;

+ (instancetype)sharedInstance;

@end

@class MKMHistory;
@class MKMHistoryBlock;

@interface MKMConsensus (History)

/**
 Run the whole history, stop when error
 
 @param history - history records
 @return Cout of success
 */
- (NSUInteger)runHistory:(const MKMHistory *)history
               forEntity:(MKMEntity *)entity;

/**
 Run one new history record
 
 @param record - history record
 @return YES when success
 */
- (BOOL)runHistoryBlock:(const MKMHistoryBlock *)record
              forEntity:(MKMEntity *)entity;

@end

NS_ASSUME_NONNULL_END
