//
//  DIMSocialNetworkDatabase.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMSocialNetworkDatabase <DIMUserDataSource, DIMGroupDataSource>

// Address Name Service
- (BOOL)saveANSRecord:(DIMID *)ID forName:(NSString *)name;
- (DIMID *)ansRecordForName:(NSString *)name;
- (NSArray<DIMID *> *)namesWithANSRecord:(NSString *)ID;

- (nullable NSArray<DIMID *> *)allUsers;
- (BOOL)saveUsers:(NSArray<DIMID *> *)list;
- (BOOL)saveUser:(DIMID *)user;
- (BOOL)removeUser:(DIMID *)user;

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID;
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user;
- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group;

@end

@interface DIMSocialNetworkDatabase : NSObject <DIMSocialNetworkDatabase>

@end

NS_ASSUME_NONNULL_END
