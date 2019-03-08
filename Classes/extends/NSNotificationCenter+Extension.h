//
//  NSNotificationCenter+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/8.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (Extension)

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;

+ (void)postNotification:(NSNotification *)notification;
+ (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject;
+ (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject;

@end

NS_ASSUME_NONNULL_END
