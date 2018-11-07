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

#pragma mark - Entity History Delegates

@protocol MKMEntityHistoryDataSource <NSObject>

- (MKMHistory *)historyForEntityID:(const MKMID *)ID;

@end

@class MKMEntity;
@class MKMHistoryTransaction;
@class MKMHistoryOperation;

@protocol MKMEntityHistoryDelegate <NSObject>

/**
 Check whether a record(Block) can write to the entity's evolving history
 
 @param entity - Account/Group
 @param record - history record
 @return YES/NO
 */
- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record;

/**
 Check whether an event(Transaction) can run for the entity
 
 @param entity - Account/Group
 @param event - history transaction
 @param recorder - history recorder's ID
 @return YES/NO
 */
- (BOOL)evolvingEntity:(const MKMEntity *)entity
           canRunEvent:(const MKMHistoryTransaction *)event
              recorder:(const MKMID *)recorder;

/**
 Run operation
 
 @param entity - User/Group
 @param operation - history operation
 @param commander - commander's ID
 */
- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander;

@end

NS_ASSUME_NONNULL_END
