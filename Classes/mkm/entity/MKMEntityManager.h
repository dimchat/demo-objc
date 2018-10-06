//
//  MKMEntityManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;
@class MKMHistoryRecord;
@class MKMHistory;

@protocol MKMEntityDelegate;

@interface MKMEntityManager : NSObject

@property (weak, nonatomic) id<MKMEntityDelegate> delegate;

+ (instancetype)sharedManager;

// meta
- (MKMMeta *)metaWithID:(const MKMID *)ID;
- (BOOL)setMeta:(const MKMMeta *)meta forID:(const MKMID *)ID;

// history
- (MKMHistory *)historyWithID:(const MKMID *)ID;
- (NSUInteger)setHistory:(const MKMHistory *)history forID:(const MKMID *)ID;
- (BOOL)addHistoryRecord:(const MKMHistoryRecord *)record forID:(const MKMID *)ID;

- (BOOL)setMeta:(const MKMMeta *)meta
        history:(const MKMHistory *)history
          forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
