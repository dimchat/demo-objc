//
//  DIMClient.h
//  DIM
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;
@class DIMConnection;

@interface DIMClient : NSObject <DIMConnectionDelegate>

@property (strong, nonatomic) DIMUser *currentUser;

@property (strong, nonatomic) DIMConnection *currentConnection;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

- (BOOL)connect:(DIMStation *)station;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
