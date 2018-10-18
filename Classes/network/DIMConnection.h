//
//  DIMConnection.h
//  DIM
//
//  Created by Albert Moky on 2018/10/18.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMClient;
@class DIMStation;
@class DIMConnection;

@protocol DIMConnector <NSObject>

/**
 Connection to station, from client

 @param srv - station
 @param cli - client
 @return connection that connected to the server
 */
- (DIMConnection *)connectToStation:(const DIMStation *)srv
                             client:(const DIMClient *)cli;

/**
 Disconnect

 @param conn - connection
 */
- (void)closeConnection:(const DIMConnection *)conn;

@end

@protocol DIMConnectionDelegate <NSObject>

/**
 Callback when receive data

 @param conn - connection
 @param data - received data
 */
- (void)connection:(const DIMConnection *)conn didReceiveData:(NSData *)data;

@optional
- (void)connection:(const DIMConnection *)conn didSendData:(NSData *)data;
- (void)connection:(const DIMConnection *)conn didFailWithError:(NSError *)error;

@end

@interface DIMConnection : NSObject

@property (readonly, strong, nonatomic) DIMStation *target;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

@property (weak, nonatomic) id<DIMConnectionDelegate> delegate;

- (instancetype)initWithTargetStation:(const DIMStation *)station
NS_DESIGNATED_INITIALIZER;

/**
 Send data to target station

 @param jsonData - json data pack
 @return YES on success
 */
- (BOOL)sendData:(const NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
