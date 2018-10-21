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

@protocol DIMConnectionDelegate;

@interface DIMConnection : NSObject {
    
    DIMStation * _target;
    BOOL _connected;
    
    __weak id<DIMConnectionDelegate> _delegate;
}

@property (readonly, strong, nonatomic) DIMStation *target;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

@property (weak, nonatomic) id<DIMConnectionDelegate> delegate;

- (instancetype)initWithTargetStation:(DIMStation *)station
NS_DESIGNATED_INITIALIZER;

/**
 Send data to the target station
 
 @param jsonData - json data pack
 @return YES on success
 */
- (BOOL)sendData:(const NSData *)jsonData;

/**
 Callback for receive data

 @param jsonData - received data
 */
- (void)receiveData:(const NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
