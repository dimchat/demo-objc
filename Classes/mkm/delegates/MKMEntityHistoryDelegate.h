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
@class MKMHistoryRecord;

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
 @param operation - history event operation
 @param entity - User/Group
 @return YES/ON
 */
- (BOOL)commander:(const MKMID *)ID
       canExecute:(const MKMHistoryOperation *)operation
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

@interface MKMEntityHistoryDelegate : NSObject <MKMEntityHistoryDelegate>

@end

NS_ASSUME_NONNULL_END
