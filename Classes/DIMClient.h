//
//  DIMClient.h
//  DIM
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMClient : NSObject

@property (strong, nonatomic) DIMUser *currentUser;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;

- (void)removeUser:(DIMUser *)user;

@end

NS_ASSUME_NONNULL_END
