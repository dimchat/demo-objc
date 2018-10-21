//
//  DIMConnectionDelegate.h
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMConnection;

@protocol DIMConnectionDelegate <NSObject>

/**
 Callback when receive data
 
 @param conn - connection
 @param data - received data
 */
- (void)connection:(const DIMConnection *)conn didReceiveData:(const NSData *)data;

@optional
- (void)connection:(const DIMConnection *)conn didSendData:(const NSData *)data;
- (void)connection:(const DIMConnection *)conn didFailWithError:(const NSError *)error;

@end

NS_ASSUME_NONNULL_END
