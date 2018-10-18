//
//  DIMConnection.h
//  DIM
//
//  Created by Albert Moky on 2018/10/18.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;
@class DIMConnection;

@protocol DIMConnectionDelegate <NSObject>

- (void)connection:(const DIMConnection *)conn didReceiveData:(NSData *)data;

@end

@interface DIMConnection : NSObject

@property (readonly, strong, nonatomic) DIMStation *target;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

@property (weak, nonatomic) id<DIMConnectionDelegate> delegate;

- (instancetype)initWithTargetStation:(const DIMStation *)station
NS_DESIGNATED_INITIALIZER;

/**
 Connect to target station

 @return YES on success
 */
- (BOOL)connect;

/**
 Disconnect target station
 */
- (void)disconnect;

/**
 Send data to target station

 @param jsonData - json data pack
 @return YES on success
 */
- (BOOL)sendData:(const NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
