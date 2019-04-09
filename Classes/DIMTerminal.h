//
//  DIMTerminal.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMServer;

@interface DIMTerminal : NSObject <DIMStationDelegate> {
    
    DIMServer *_currentStation;
    NSString *_session;
    
    NSMutableArray<DIMUser *> *_users;
}

@property (readonly, nonatomic) NSString *userAgent;
@property (readonly, nonatomic) NSString *language;

#pragma mark - User(s)

@property (readonly, copy, nonatomic) NSArray<DIMUser *> *users;
@property (strong, nonatomic) DIMUser *currentUser;

- (void)addUser:(DIMUser *)user;
- (void)removeUser:(DIMUser *)user;

@end

NS_ASSUME_NONNULL_END
