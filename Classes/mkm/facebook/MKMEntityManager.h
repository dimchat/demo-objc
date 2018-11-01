//
//  MKMEntityManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MKMEntityPool()          [MKMEntityManager sharedInstance]

#define MKMContactWithID(ID)     [MKMEntityPool() contactWithID:(ID)]
#define MKMUserWithID(ID)        [MKMEntityPool() userWithID:(ID)]

#define MKMGroupWithID(ID)       [MKMEntityPool() groupWithID:(ID)]
#define MKMMemberWithID(ID, gID) [MKMEntityPool() memberWithID:(ID) groupID:(gID)]

@class MKMID;

@class MKMContact;
@class MKMUser;

@class MKMGroup;
@class MKMMember;

@protocol MKMEntityDelegate <NSObject>

- (MKMContact *)contactWithID:(const MKMID *)ID;
- (MKMUser *)userWithID:(const MKMID *)ID;

- (MKMGroup *)groupWithID:(const MKMID *)ID;
- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID;

@end

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface MKMEntityManager : NSObject <MKMEntityDelegate>

@property (weak, nonatomic) id<MKMEntityDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)addContact:(MKMContact *)contact;
- (void)addUser:(MKMUser *)user;

- (void)addGroup:(MKMGroup *)group;
- (void)addMember:(MKMMember *)member;

- (void)reduceMemory; // remove 1/2 objects

@end

//@class MKMID;
//@class MKMMeta;
//@class MKMHistoryRecord;
//@class MKMHistory;
//
//@protocol MKMEntityDataSource <NSObject>
//
//// query
//- (MKMMeta *)metaForEntityID:(const MKMID *)ID;
//- (MKMHistory *)historyForEntityID:(const MKMID *)ID;
//
//@end
//
//@protocol MKMEntityDelegate <NSObject>
//
//// send
//- (void)entityID:(const MKMID *)ID sendMeta:(const MKMMeta *)meta;
//- (void)entityID:(const MKMID *)ID sendHistory:(const MKMHistory *)history;
//- (void)entityID:(const MKMID *)ID sendHistoryRecord:(const MKMHistoryRecord *)record;
//
//// receive
//- (void)entityID:(const MKMID *)ID didReceiveMeta:(const MKMMeta *)meta;
//- (void)entityID:(const MKMID *)ID didReceiveHistory:(const MKMHistory *)history;
//- (void)entityID:(const MKMID *)ID didReceiveHistoryRecord:(const MKMHistoryRecord *)record;
//
//@end
//
//#pragma mark -
//
//#define MKMMetaForID(ID) [[MKMEntityManager sharedInstance] metaForID:(ID)]
//#define MKMHistoryForID(ID) [[MKMEntityManager sharedInstance] historyForID:(ID)]
//#define MKMPublicKeyForAccountID(ID) MKMMetaForID(ID).key
//
//@interface MKMEntityManager : NSObject
//
//@property (weak, nonatomic) id<MKMEntityDataSource> dataSource;
//
//
//// meta
//- (MKMMeta *)metaForID:(const MKMID *)ID;
//- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID;
//- (void)sendMetaForID:(const MKMID *)ID;
//
//// history
//- (MKMHistory *)historyForID:(const MKMID *)ID;
//- (void)setHistory:(MKMHistory *)history forID:(const MKMID *)ID;
//- (void)sendHistoryForID:(const MKMID *)ID;
//- (void)sendHistoryRecord:(MKMHistoryRecord *)record forID:(const MKMID *)ID;
//
//@end

NS_ASSUME_NONNULL_END
