//
//  NSObject+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/24.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(when, queue, block);
}

@end
