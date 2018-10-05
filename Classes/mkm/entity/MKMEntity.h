//
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;

@class MKMHistoryOperation;
@class MKMHistoryEvent;
@class MKMHistoryRecord;
@class MKMHistory;

@class MKMEntity;

@protocol MKMEntityHistoryDelegate <NSObject>

/**
 Define the recorder's permission to the current entity
 
 @param ID - recorder
 @param record - history record
 @param entity - User/Group
 @return YES/NO
 */
- (BOOL)recorder:(const MKMID *)ID
  canWriteRecord:(const MKMHistoryRecord *)record
        inEntity:(const MKMEntity *)entity;

/**
 Define the commander's permission to the current entity
 
 @param ID - commander
 @param event - history event
 @param entity - User/Group
 @return YES/NO
 */
- (BOOL)commander:(const MKMID *)ID
       canDoEvent:(const MKMHistoryEvent *)event
         inEntity:(const MKMEntity *)entity;

/**
 Run operation

 @param ID - command
 @param operation - history operation
 @param entity - User/Group
 */
- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity;

@end

@interface MKMEntity : NSObject <MKMEntityHistoryDelegate> {
    
    const MKMID *_ID;
    const MKMHistory *_history;
}

@property (readonly, strong, nonatomic) const MKMID *ID;

@property (readonly, nonatomic) NSUInteger number;

@property (weak, nonatomic) id<MKMEntityHistoryDelegate> historyDelegate;

/**
 Initialize a contact without checking

 @param ID - User/Group ID
 @return Entity object
 */
- (instancetype)initWithID:(const MKMID *)ID;

/**
 Initialize an entity

 @param ID - User/Group ID
 @param meta - meta info includes PK, CT, ...
 @return Entity object
 */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

@end

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

/**
 Check the new history record
 
 @param record - history record
 @return YES when correct
 */
- (BOOL)checkHistoryRecord:(const MKMHistoryRecord *)record;

@end

NS_ASSUME_NONNULL_END
