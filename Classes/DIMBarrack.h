//
//  DIMBarrack.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMUserForID(ID)    [[DIMBarrack sharedInstance] userForID:(ID)]
#define DIMContactForID(ID) [[DIMBarrack sharedInstance] contactForID:(ID)]
#define DIMGroupForID(ID)   [[DIMBarrack sharedInstance] groupForID:(ID)]

/**
 *  Entity pool to manage User/Contace/Group instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMBarrack : NSObject

+ (instancetype)sharedInstance;

// user
- (DIMUser *)userForID:(const MKMID *)ID; // if not found, create new one
- (void)setUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

// contact
- (DIMContact *)contactForID:(const MKMID *)ID; // if not found, create new one
- (void)setContact:(DIMContact *)contact;
- (void)removeContact:(DIMContact *)contact;

// group
- (DIMGroup *)groupForID:(const MKMID *)ID; // if not found, create new one
- (void)setGroup:(DIMGroup *)group;
- (void)removeGroup:(DIMGroup *)group;

@end

NS_ASSUME_NONNULL_END
