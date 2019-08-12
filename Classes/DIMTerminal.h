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
    
    NSMutableArray<DIMLocalUser *> *_users;
}

/**
 *  format: "DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1"
 */
@property (readonly, nonatomic, nullable) NSString *userAgent;

@property (readonly, nonatomic) NSString *language;

#pragma mark - User(s)

@property (readonly, copy, nonatomic) NSArray<DIMLocalUser *> *users;
@property (strong, nonatomic) DIMLocalUser *currentUser;

- (void)addUser:(DIMLocalUser *)user;
- (void)removeUser:(DIMLocalUser *)user;

@end

NS_ASSUME_NONNULL_END
