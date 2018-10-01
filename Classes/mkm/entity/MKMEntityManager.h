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
@class MKMHistory;

@class MKMEntityManager;

@protocol MKMEntityDelegate <NSObject>

- (MKMMeta *)queryMetaWithID:(const MKMID *)ID;

- (MKMHistory *)updateHistoryWithID:(const MKMID *)ID;

@end

@interface MKMEntityManager : NSObject

@property (weak, nonatomic) id<MKMEntityDelegate> delegate;

+ (instancetype)sharedManager;

- (MKMMeta *)metaWithID:(const MKMID *)ID;
- (MKMHistory *)historyWithID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
