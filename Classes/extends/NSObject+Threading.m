//
//  NSObject+Threading.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/24.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Threading.h"

@implementation NSObject (MainThread)

+ (void)performBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)wait {
    if (wait) {
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_main_queue(), block);
}

@end

@implementation NSObject (Background)

+ (void)performBlockInBackground:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   block);
}

+ (void)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   block);
}

@end
