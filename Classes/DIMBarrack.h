//
//  DIMBarrack.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMUserWithID(ID)    [[DIMBarrack sharedInstance] userWithID:(ID)]
#define DIMContactWithID(ID) [[DIMBarrack sharedInstance] contactWithID:(ID)]
#define DIMGroupWithID(ID)   [[DIMBarrack sharedInstance] groupWithID:(ID)]

/**
 *  Entity pool to manage User/Contace/Group instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMBarrack : NSObject

+ (instancetype)sharedInstance;

// user
- (DIMUser *)userWithID:(const MKMID *)ID; // if not found, create new one
- (void)setUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

// contact
- (DIMContact *)contactWithID:(const MKMID *)ID; // if not found, create new one
- (void)setContact:(DIMContact *)contact;
- (void)removeContact:(DIMContact *)contact;

// group
- (DIMGroup *)groupWithID:(const MKMID *)ID; // if not found, create new one
- (void)setGroup:(DIMGroup *)group;
- (void)removeGroup:(DIMGroup *)group;

@end

NS_ASSUME_NONNULL_END
