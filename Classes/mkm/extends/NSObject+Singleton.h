//
//  NSObject+Singleton.h
//  MKM
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef NSObject_Singleton_h
#define NSObject_Singleton_h

#define SingletonImplementations_Main(Class, factory)          \
        static Class *s_sharedInstance = nil;                  \
        + (instancetype)allocWithZone:(struct _NSZone *)zone { \
            static dispatch_once_t onceToken;                  \
            dispatch_once(&onceToken, ^{                       \
                s_sharedInstance = [super allocWithZone:zone]; \
            });                                                \
            return s_sharedInstance;                           \
        }                                                      \
        + (instancetype)factory {                              \
            static dispatch_once_t onceToken;                  \
            dispatch_once(&onceToken, ^{                       \
                s_sharedInstance = [[self alloc] init];        \
            });                                                \
            return s_sharedInstance;                           \
        }                                                      \
       /* EOF 'SingletonImplementations_Main(Class, factory)' */

#define SingletonImplementations_Copy()                        \
        - (id)copy {                                           \
            return s_sharedInstance;                           \
        }                                                      \
        - (id)mutableCopy {                                    \
            return s_sharedInstance;                           \
        }                                                      \
                     /* EOF 'SingletonImplementations_Copy()' */

#if __has_feature(objc_arc) // ARC

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy()                        \
            /* EOF 'SingletonImplementations(Class, factory)' */

#else // MRC

#define SingletonImplementations_MRC()                         \
        - (instancetype)retain {                               \
            return s_sharedInstance;                           \
        }                                                      \
        - (oneway void)release {                               \
        }                                                      \
        - (instancetype)autorelease {                          \
            return s_sharedInstance;                           \
        }                                                      \
        - (NSUInteger)retainCount {                            \
            return MAXFLOAT;                                   \
        }                                                      \
                      /* EOF 'SingletonImplementations_MRC()' */

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy()                        \
        SingletonImplementations_MRC()                         \
            /* EOF 'SingletonImplementations(Class, factory)' */

#endif /* __has_feature(objc_arc) */

#endif /* NSObject_Singleton_h */
