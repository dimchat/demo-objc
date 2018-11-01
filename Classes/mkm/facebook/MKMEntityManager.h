//
//  MKMEntityManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;
@class MKMHistoryRecord;
@class MKMHistory;

@protocol MKMEntityDataSource <NSObject>

// query
- (MKMMeta *)metaForEntityID:(const MKMID *)ID;
- (MKMHistory *)historyForEntityID:(const MKMID *)ID;

@end

@protocol MKMEntityDelegate <NSObject>

// send
- (void)entityID:(const MKMID *)ID sendMeta:(const MKMMeta *)meta;
- (void)entityID:(const MKMID *)ID sendHistory:(const MKMHistory *)history;
- (void)entityID:(const MKMID *)ID sendHistoryRecord:(const MKMHistoryRecord *)record;

// receive
- (void)entityID:(const MKMID *)ID didReceiveMeta:(const MKMMeta *)meta;
- (void)entityID:(const MKMID *)ID didReceiveHistory:(const MKMHistory *)history;
- (void)entityID:(const MKMID *)ID didReceiveHistoryRecord:(const MKMHistoryRecord *)record;

@end

#pragma mark -

#define MKMMetaForID(ID) [[MKMEntityManager sharedInstance] metaForID:(ID)]
#define MKMHistoryForID(ID) [[MKMEntityManager sharedInstance] historyForID:(ID)]
#define MKMPublicKeyForAccountID(ID) MKMMetaForID(ID).key

@interface MKMEntityManager : NSObject

@property (weak, nonatomic) id<MKMEntityDataSource> dataSource;
@property (weak, nonatomic) id<MKMEntityDelegate> delegate;

+ (instancetype)sharedInstance;

// meta
- (MKMMeta *)metaForID:(const MKMID *)ID;
- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID;
- (void)sendMetaForID:(const MKMID *)ID;

// history
- (MKMHistory *)historyForID:(const MKMID *)ID;
- (void)setHistory:(MKMHistory *)history forID:(const MKMID *)ID;
- (void)sendHistoryForID:(const MKMID *)ID;
- (void)sendHistoryRecord:(MKMHistoryRecord *)record forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
