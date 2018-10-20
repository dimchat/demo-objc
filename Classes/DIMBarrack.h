//
//  DIMBarrack.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Entity pool to manage User/Contace/Group instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMBarrack : NSObject <MKMEntityDelegate, MKMProfileDelegate>

+ (instancetype)sharedInstance;

// user
- (DIMUser *)userForID:(const MKMID *)ID; // if not found, create new one
- (void)setUser:(DIMUser *)user;
- (void)removeUser:(const DIMUser *)user;

// contact
- (DIMContact *)contactForID:(const MKMID *)ID; // if not found, create new one
- (void)setContact:(DIMContact *)contact;
- (void)removeContact:(const DIMContact *)contact;

// group
- (DIMGroup *)groupForID:(const MKMID *)ID; // if not found, create new one
- (void)setGroup:(DIMGroup *)group;
- (void)removeGroup:(const DIMGroup *)group;

@end

NS_ASSUME_NONNULL_END
