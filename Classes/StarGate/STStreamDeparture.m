// license: https://mit-license.org
//
//  Star Gate: Network Connection Module
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
//  STStreamDeparture.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamDeparture.h"

@interface STPlainDeparture ()

@property(nonatomic, strong) NSData *package;

@end

@implementation STPlainDeparture

- (instancetype)initWithData:(NSData *)pack priority:(NSInteger)prior {
    if (self = [super initWithPriority:prior maxTries:1]) {
        self.package = pack;
    }
    return self;
}

// Override
- (id<STShipID>)sn {
    // plain ship has no SN
    return nil;
}

// Override
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[STPlainDeparture class]]) {
        if (object == self) {
            return YES;
        }
        STPlainDeparture *other = (STPlainDeparture *)object;
        return [other.package isEqual:_package];
    }
    return NO;
}

// Override
- (NSUInteger)hash {
    return [_package hash];
}

// Override
- (NSArray<NSData *> *)fragments {
    return @[_package];
}

// Override
- (BOOL)checkResponseWithinArrivalShip:(id<STArrival>)response {
    // plain departure needs no response
    return NO;
}

// Override
- (BOOL)isImportant {
    // plain departure needs no response
    return NO;
}

@end

@implementation STStreamDeparture

@end
