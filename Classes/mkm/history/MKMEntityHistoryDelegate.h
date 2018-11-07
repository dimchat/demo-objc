//
//  MKMEntityHistoryDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMEntity;

@class MKMHistoryOperation;
@class MKMHistoryBlock;

@protocol MKMEntityHistoryDelegate <NSObject>

/**
 Define the recorder's permission to the current entity
 
 @param recorder - recorder ID
 @param record - history record
 @param entity - User/Group
 @return YES/NO
 */
- (BOOL)historyRecorder:(const MKMID *)recorder
          canWriteBlock:(const MKMHistoryBlock *)record
               inEntity:(const MKMEntity *)entity;

/**
 Define the commander's permission to the current entity
 
 @param commander - commander ID
 @param operation - history event operation
 @param entity - User/Group
 @return YES/ON
 */
- (BOOL)historyCommander:(const MKMID *)commander
              canExecute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity;

/**
 Run operation
 
 @param commander - commander ID
 @param operation - history operation
 @param entity - User/Group
 */
- (void)historyCommander:(const MKMID *)commander
                 execute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity;

@end

@interface MKMEntityHistoryDelegate : NSObject <MKMEntityHistoryDelegate>

@end

NS_ASSUME_NONNULL_END
