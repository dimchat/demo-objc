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
@class MKMHistoryRecord;
@class MKMHistory;

@interface MKMEntity : NSObject {
    
    const MKMHistory *_history;
}

@property (readonly, strong, nonatomic) const MKMID *ID;

@property (readonly, nonatomic) NSUInteger number;

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
