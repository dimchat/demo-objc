//
//  MKMBarrack.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"
#import "MKMAccount.h"

#import "MKMContact.h"
#import "MKMUser.h"
#import "MKMChatroom.h"
#import "MKMMember.h"

#import "MKMProfile.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMFacebook()            [MKMBarrack sharedInstance]

#define MKMContactWithID(ID)     [MKMFacebook() contactWithID:(ID)]
#define MKMUserWithID(ID)        [MKMFacebook() userWithID:(ID)]

#define MKMGroupWithID(ID)       [MKMFacebook() groupWithID:(ID)]
#define MKMMemberWithID(ID, gID) [MKMFacebook() memberWithID:(ID) groupID:(gID)]

#define MKMMetaForID(ID)         [MKMFacebook() metaForEntityID:(ID)]
#define MKMPublicKeyForID(ID)    [MKMFacebook() publicKeyForAccountID:(ID)]
#define MKMProfileForID(ID)      [MKMFacebook() profileForID:(ID)]

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface MKMBarrack : NSObject <MKMUserDelegate, MKMContactDelegate, MKMGroupDelegate, MKMMemberDelegate, MKMEntityDataSource, MKMAccountDataSource, MKMProfileDataSource>

@property (weak, nonatomic) id<MKMUserDelegate> userDelegate;
@property (weak, nonatomic) id<MKMContactDelegate> contactDelegate;

@property (weak, nonatomic) id<MKMGroupDelegate> groupDelegate;
@property (weak, nonatomic) id<MKMMemberDelegate> memberDelegate;

@property (weak, nonatomic) id<MKMEntityDataSource> entityDataSource;
@property (weak, nonatomic) id<MKMAccountDataSource> accountDataSource;
@property (weak, nonatomic) id<MKMProfileDataSource> profileDataSource;

+ (instancetype)sharedInstance;

- (void)addContact:(MKMContact *)contact;
- (void)addUser:(MKMUser *)user;

- (void)addGroup:(MKMGroup *)group;
- (void)addMember:(MKMMember *)member;

- (void)addProfile:(MKMProfile *)profile;

/**
 Call it when receive 'UIApplicationDidReceiveMemoryWarningNotification',
 this will remove 50% of unused objects from the cache
 */
- (void)reduceMemory;

@end

NS_ASSUME_NONNULL_END
