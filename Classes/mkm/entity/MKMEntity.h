//
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;

@class MKMHistory;

@protocol MKMEntityHistoryDelegate;

@interface MKMEntity : NSObject {
    
    const MKMID *_ID;
    MKMHistory *_history;
}

@property (readonly, strong, nonatomic) const MKMID *ID;

@property (readonly, nonatomic) NSUInteger number;

@property (weak, nonatomic) id<MKMEntityHistoryDelegate> historyDelegate;

/**
 Initialize an entity

 @param ID - Contact/Group ID
 @return Entity object
 */
- (instancetype)initWithID:(const MKMID *)ID;

/**
 Initialize an entity with given meta info

 @param ID - User/Contact/Group ID
 @param meta - meta info includes PK, CT, ...
 @return Entity object
 */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
