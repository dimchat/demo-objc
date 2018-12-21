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
    
    MKMUser *_currentUser;
    DIMStation *_currentStation;
}

@property (strong, nonatomic) MKMUser *currentUser;
@property (readonly, strong, nonatomic) NSArray<MKMUser *> *users;

@property (strong, nonatomic) DIMStation *currentStation;
@property (readonly, nonatomic) NSString *userAgent;

+ (instancetype)sharedInstance;

- (void)addUser:(MKMUser *)user;
- (void)removeUser:(MKMUser *)user;

@end

NS_ASSUME_NONNULL_END
