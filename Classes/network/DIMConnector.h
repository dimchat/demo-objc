//
//  DIMConnector.h
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;
@class DIMConnection;

@protocol DIMConnector <NSObject>

/**
 Connect to a server
 
 @param server - station server
 @return connected connection
 */
- (DIMConnection *)connectTo:(const DIMStation *)server;

/**
 Close a connectiion

 @param connection - connected connection
 */
- (void)closeConnection:(const DIMConnection *)connection;

@end

NS_ASSUME_NONNULL_END
