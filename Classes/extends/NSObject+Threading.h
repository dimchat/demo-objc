//
//  NSObject+Threading.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/24.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MainThread)

+ (void)performBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)wait;
+ (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end

@interface NSObject (Background)

+ (void)performBlockInBackground:(void (^)(void))block;
+ (void)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
