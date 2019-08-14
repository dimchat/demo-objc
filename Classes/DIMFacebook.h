//
//  DIMFacebook.h
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMMetaForID(ID)         [[DIMFacebook sharedInstance] metaForID:(ID)]
#define DIMProfileForID(ID)      [[DIMFacebook sharedInstance] profileForID:(ID)]

#define DIMIDWithString(ID)      [[DIMFacebook sharedInstance] IDWithString:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@interface DIMFacebook : DIMBarrack

@property (weak, nonatomic, nullable) id<DIMEntityDataSource> entityDataSource;
@property (weak, nonatomic, nullable) id<DIMUserDataSource> userDataSource;
@property (weak, nonatomic, nullable) id<DIMGroupDataSource> groupDataSource;

+ (instancetype)sharedInstance;

- (BOOL)cacheProfile:(DIMProfile *)profile;

@end

@interface DIMFacebook (Relationship)

- (BOOL)user:(DIMLocalUser *)user addContact:(DIMID *)contact;
- (BOOL)user:(DIMLocalUser *)user removeContact:(DIMID *)contact;

- (BOOL)group:(DIMGroup *)group addMember:(DIMID *)member;
- (BOOL)group:(DIMGroup *)group removeMember:(DIMID *)member;

@end

NS_ASSUME_NONNULL_END
