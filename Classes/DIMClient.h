//
//  DIMClient.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;

@interface DIMClient : NSObject {
    
    DIMUser *_currentUser;
    DIMStation *_currentStation;
}

@property (strong, nonatomic) DIMUser *currentUser;
@property (readonly, strong, nonatomic) NSArray<DIMUser *> *users;

@property (strong, nonatomic) DIMStation *currentStation;
@property (readonly, nonatomic) NSString *userAgent;

+ (instancetype)sharedInstance;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

@end

NS_ASSUME_NONNULL_END
