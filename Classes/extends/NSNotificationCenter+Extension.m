//
//  NSNotificationCenter+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/8.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"

@implementation NSNotificationCenter (MainThread)

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable const NSString *)aName object:(nullable id)anObject {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:observer selector:aSelector name:(NSNotificationName)aName object:anObject];
}

+ (void)postNotification:(NSNotification *)notification {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

+ (void)postNotificationName:(const NSString *)aName object:(nullable id)anObject {
    [self postNotificationName:aName object:anObject userInfo:nil];
}

+ (void)postNotificationName:(const NSString *)aName
                      object:(nullable id)anObject
                    userInfo:(nullable NSDictionary *)aUserInfo {
    NSNotification *noti = [[NSNotification alloc] initWithName:(NSNotificationName)aName
                                                         object:anObject
                                                       userInfo:aUserInfo];
    [self postNotification:noti];
}

+ (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

+ (void)removeObserver:(id)observer name:(nullable const NSString *)aName object:(nullable id)anObject {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:observer name:(NSNotificationName)aName object:anObject];
}

@end
