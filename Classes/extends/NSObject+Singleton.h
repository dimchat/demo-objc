// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  NSObject+Singleton.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef NSObject_Singleton_h
#define NSObject_Singleton_h

#define SingletonDispatchOnce(block)                           \
            static dispatch_once_t onceToken;                  \
            dispatch_once(&onceToken, block)                   \
                        /* EOF 'SingletonDispatchOnce(block)' */

#define SingletonImplementations_Main(Class, factory)          \
        static Class *s_shared##Class = nil;                   \
        + (instancetype)allocWithZone:(struct _NSZone *)zone { \
            SingletonDispatchOnce(^{                           \
                s_shared##Class = [super allocWithZone:zone];  \
            });                                                \
            return s_shared##Class;                            \
        }                                                      \
        + (instancetype)factory {                              \
            SingletonDispatchOnce(^{                           \
                s_shared##Class = [[self alloc] init];         \
            });                                                \
            return s_shared##Class;                            \
        }                                                      \
       /* EOF 'SingletonImplementations_Main(Class, factory)' */

#define SingletonImplementations_Copy(Class)                   \
        - (id)copy {                                           \
            return s_shared##Class;                            \
        }                                                      \
        - (id)mutableCopy {                                    \
            return s_shared##Class;                            \
        }                                                      \
                     /* EOF 'SingletonImplementations_Copy()' */

#if __has_feature(objc_arc) // ARC

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy(Class)                   \
            /* EOF 'SingletonImplementations(Class, factory)' */

#else // MRC

#define SingletonImplementations_MRC(Class)                    \
        - (instancetype)retain {                               \
            return s_shared##Class;                            \
        }                                                      \
        - (oneway void)release {                               \
        }                                                      \
        - (instancetype)autorelease {                          \
            return s_shared##Class;                            \
        }                                                      \
        - (NSUInteger)retainCount {                            \
            return MAXFLOAT;                                   \
        }                                                      \
                      /* EOF 'SingletonImplementations_MRC()' */

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy(Class)                   \
        SingletonImplementations_MRC(Class)                    \
            /* EOF 'SingletonImplementations(Class, factory)' */

#endif /* __has_feature(objc_arc) */

#endif /* NSObject_Singleton_h */
