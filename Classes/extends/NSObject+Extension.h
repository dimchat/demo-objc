//
//  NSObject+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/24.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DelayBlock)

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
