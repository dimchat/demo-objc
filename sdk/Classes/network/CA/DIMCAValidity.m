// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DIMCAValidity.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMCAValidity.h"

@implementation DIMCAValidity

+ (instancetype)validityWithValidity:(id)validity {
    if ([validity isKindOfClass:[DIMCAValidity class]]) {
        return validity;
    } else if ([validity isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:validity];
    } else {
        NSAssert(!validity, @"unexpected validity: %@", validity);
        return nil;
    }
}

- (instancetype)initWithNotBefore:(NSDate *)from
                         notAfter:(NSDate *)to {
    NSDictionary *dict = @{@"NotBefore":NSNumberFromDate(from),
                           @"NotAfter" :NSNumberFromDate(to),
                           };
    if (self = [super initWithDictionary:dict]) {
        _notBefore = from;
        _notAfter = to;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMCAValidity *validity = [super copyWithZone:zone];
    if (validity) {
        validity.notBefore = _notBefore;
        validity.notAfter = _notAfter;
    }
    return validity;
}

- (NSDate *)notBefore {
    if (!_notBefore) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"NotBefore"];
        NSAssert(timestamp != nil, @"error: %@", _storeDictionary);
        _notBefore = NSDateFromNumber(timestamp);
    }
    return _notBefore;
}

- (NSDate *)notAfter {
    if (!_notAfter) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"NotAfter"];
        NSAssert(timestamp != nil, @"error: %@", _storeDictionary);
        _notAfter = NSDateFromNumber(timestamp);
    }
    return _notAfter;
}

@end
