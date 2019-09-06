//
//  DIMDatabase.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMDatabase <DIMUserDataSource, DIMGroupDataSource>

+ (instancetype)sharedInstance;

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID;
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user;
- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group;

@end

@interface DIMDatabase : NSObject <DIMDatabase>

@end

NS_ASSUME_NONNULL_END
