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

#define DIMIDWithAddress(addr)   [[DIMFacebook sharedInstance] IDWithAddress:(addr)]
#define DIMIDWithString(ID)      [[DIMFacebook sharedInstance] IDWithString:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@protocol DIMSocialNetworkDatabase;

@interface DIMFacebook : DIMBarrack

@property (weak, nonatomic, nullable) id<DIMSocialNetworkDatabase> database;

+ (instancetype)sharedInstance;

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address;

@end

@interface DIMFacebook (Storage)

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID;
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user;
- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group;

@end

@interface DIMFacebook (Relationship)

- (BOOL)user:(DIMLocalUser *)user hasContact:(DIMID *)contact;
- (BOOL)user:(DIMLocalUser *)user addContact:(DIMID *)contact;
- (BOOL)user:(DIMLocalUser *)user removeContact:(DIMID *)contact;

- (BOOL)group:(DIMGroup *)group addMember:(DIMID *)member;
- (BOOL)group:(DIMGroup *)group removeMember:(DIMID *)member;

/**
 *  Get group assistants
 *
 * @param group - group ID
 * @return owner ID
 */
- (nullable NSArray<DIMID *> *)assistantsOfGroup:(DIMID *)group;

@end

NS_ASSUME_NONNULL_END
