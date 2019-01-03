//
//  MKMBarrack.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"
#import "MKMAccount.h"

#import "MKMUser.h"
#import "MKMChatroom.h"
#import "MKMMember.h"

#import "MKMProfile.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMFacebook()            [MKMBarrack sharedInstance]

#define MKMAccountWithID(ID)     [MKMFacebook() accountWithID:(ID)]
#define MKMUserWithID(ID)        [MKMFacebook() userWithID:(ID)]

#define MKMGroupWithID(ID)       [MKMFacebook() groupWithID:(ID)]
#define MKMMemberWithID(ID, gID) [MKMFacebook() memberWithID:(ID) groupID:(gID)]

#define MKMMetaForID(ID)         [MKMFacebook() metaForEntityID:(ID)]
#define MKMPublicKeyForID(ID)    MKMMetaForID(ID).key
#define MKMProfileForID(ID)      [MKMFacebook() profileForID:(ID)]

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface MKMBarrack : NSObject <MKMAccountDelegate,
                                  MKMUserDataSource,
                                  MKMUserDelegate,
                                  //-
                                  MKMGroupDataSource,
                                  MKMGroupDelegate,
                                  MKMMemberDelegate,
                                  MKMChatroomDataSource,
                                  //-
                                  MKMEntityDataSource,
                                  MKMProfileDataSource>

@property (weak, nonatomic) id<MKMAccountDelegate> accountDelegate;
@property (weak, nonatomic) id<MKMUserDataSource> userDataSource;
@property (weak, nonatomic) id<MKMUserDelegate> userDelegate;

@property (weak, nonatomic) id<MKMGroupDataSource> groupDataSource;
@property (weak, nonatomic) id<MKMGroupDelegate> groupDelegate;
@property (weak, nonatomic) id<MKMMemberDelegate> memberDelegate;
@property (weak, nonatomic) id<MKMChatroomDataSource> chatroomDataSource;

@property (weak, nonatomic) id<MKMEntityDataSource> entityDataSource;
@property (weak, nonatomic) id<MKMProfileDataSource> profileDataSource;

+ (instancetype)sharedInstance;

- (void)addAccount:(MKMAccount *)account;
- (void)addUser:(MKMUser *)user;

- (void)addGroup:(MKMGroup *)group;
- (void)addMember:(MKMMember *)member;

- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID;

/**
 Call it when receive 'UIApplicationDidReceiveMemoryWarningNotification',
 this will remove 50% of unused objects from the cache
 */
- (void)reduceMemory;

@end

NS_ASSUME_NONNULL_END
