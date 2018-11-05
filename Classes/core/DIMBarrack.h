//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMFacebook()            [DIMBarrack sharedInstance]

#define DIMContactWithID(ID)     [DIMFacebook() contactWithID:(ID)]
#define DIMUserWithID(ID)        [DIMFacebook() userWithID:(ID)]

#define DIMGroupWithID(ID)       [DIMFacebook() groupWithID:(ID)]
#define DIMMemberWithID(ID, gID) [DIMFacebook() memberWithID:(ID) groupID:(gID)]

#define DIMProfileForID(ID)      [DIMFacebook() profileForID:(ID)]

@class DIMUser;
@class DIMContact;

@class DIMGroup;
@class DIMMember;

@protocol DIMAccountDelegate <NSObject>

- (DIMUser *)userWithID:(const MKMID *)ID;
- (DIMContact *)contactWithID:(const MKMID *)ID;

@end

@protocol DIMGroupDelegate <NSObject>

- (DIMGroup *)groupWithID:(const MKMID *)ID;
- (DIMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID;

@end

@protocol DIMProfileDataSource <NSObject>

- (MKMProfile *)profileForID:(const MKMID *)ID;

@end

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <DIMAccountDelegate, DIMGroupDelegate, DIMProfileDataSource>

@property (weak, nonatomic) id<DIMAccountDelegate> accountDelegate;
@property (weak, nonatomic) id<DIMGroupDelegate> groupDelegate;
@property (weak, nonatomic) id<DIMProfileDataSource> profileDataSource;

+ (instancetype)sharedInstance;

- (void)addContact:(DIMContact *)contact;
- (void)addUser:(DIMUser *)user;

- (void)addGroup:(DIMGroup *)group;
- (void)addMember:(DIMMember *)member;

- (void)addProfile:(MKMProfile *)profile;

- (void)reduceMemory; // remove 1/2 objects

@end

NS_ASSUME_NONNULL_END
