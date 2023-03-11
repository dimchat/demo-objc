// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMFrequencyChecker.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMFrequencyChecker.h"

@interface DIMFrequencyChecker () {
    
    NSTimeInterval _expires;
    
    NSMutableDictionary<id, NSNumber *> *_records;
}

@end

@implementation DIMFrequencyChecker

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithLifeSpan:600];
}

/* designated initializer */
- (instancetype)initWithLifeSpan:(NSTimeInterval)lifeSpan {
    if (self = [super init]) {
        _expires = lifeSpan;
        _records = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)checkKey:(id)key isExpired:(NSTimeInterval)now {
    if (now < 1) {
        now = [[NSDate date] timeIntervalSince1970];
    }
    NSNumber *value = [_records objectForKey:key];
    if ([value doubleValue] > now) {
        // record exists and not expired yet
        return false;
    }
    [_records setObject:@(now + _expires) forKey:key];
    return true;
}

@end
