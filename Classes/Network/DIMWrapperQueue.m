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
//  DIMWrapperQueue.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMWrapperQueue.h"

@interface DIMMessageWrapper ()

@property(nonatomic, strong) id<DKDReliableMessage> message;

@property(nonatomic, strong) id<STDeparture> ship;

@end

@implementation DIMMessageWrapper

- (instancetype)initWithReliableMessage:(id<DKDReliableMessage>)rMsg
                          departureShip:(id<STDeparture>)outgo {
    if (self = [super init]) {
        self.message = rMsg;
        self.ship = outgo;
    }
    return self;
}

// Override
- (id<STShipID>)sn {
    return [_ship sn];
}

// Override
- (NSInteger)priority {
    return [_ship priority];
}

// Override
- (NSArray<NSData *> *)fragments {
    return [_ship fragments];
}

// Override
- (BOOL)checkResponseWithinArrivalShip:(id<STArrival>)response {
    return [_ship checkResponseWithinArrivalShip:response];
}

// Override
- (BOOL)isImportant {
    return [_ship isImportant];
}

// Override
- (void)touch:(NSTimeInterval)now {
    [_ship touch:now];
}

// Override
- (STShipStatus)status:(NSTimeInterval)now {
    return [_ship status:now];
}

@end

#pragma mark -

typedef OKArrayList<DIMMessageWrapper *> WrapperList;

@interface DIMMessageQueue ()

@property(nonatomic, strong) OKArrayList<NSNumber *> *priorities;

@property(nonatomic, strong) OKHashMap<NSNumber *, WrapperList *> *fleets;

@end

@implementation DIMMessageQueue

- (instancetype)init {
    if (self = [super init]) {
        self.priorities = [OKArrayList array];
        self.fleets = [OKHashMap dictionary];
    }
    return self;
}

- (BOOL)appendReliableMessage:(id<DKDReliableMessage>)rMsg
                departureShip:(id<STDeparture>)ship {
    __block BOOL ok = YES;
    @synchronized (self) {
        // 1. choose an array with priority
        NSInteger priority = [ship priority];
        WrapperList *array = [_fleets objectForKey:@(priority)];
        if (!array) {
            // 1.1. create new array for this priority
            array = [[OKArrayList alloc] init];
            [_fleets setObject:array forKey:@(priority)];
            // 1.2. insert the priority in a sorted list
            [self insertPriority:priority];
        } else {
            // 1.3. check duplicated
            id signature = [rMsg objectForKey:@"signature"];
            NSAssert(signature, @"signature not found: %@", rMsg);
            [array enumerateObjectsUsingBlock:^(DIMMessageWrapper *wrapper, NSUInteger idx, BOOL *stop) {
                id<DKDReliableMessage> item = [wrapper message];
                id sig = [item objectForKey:@"signature"];
                if ([signature isEqual:sig]) {
                    NSLog(@"[QUEUE] duplicated message: %@", signature);
                    ok = NO;
                    *stop = YES;
                }
            }];
        }
        if (ok) {
            // 2. append with wrapper
            DIMMessageWrapper *wrapper;
            wrapper = [[DIMMessageWrapper alloc] initWithReliableMessage:rMsg
                                                           departureShip:ship];
            [array addObject:wrapper];
        }
    }
    return ok;
}

// private
- (void)insertPriority:(NSInteger)priority {
    __block NSInteger index = 0;
    [_priorities enumerateObjectsUsingBlock:^(NSNumber *prior, NSUInteger idx, BOOL *stop) {
        NSInteger value = [prior integerValue];
        if (value == priority) {
            // duplicated
            index = -1;
            *stop = YES;
        } else if (value > priority) {
            // got it
            index = idx;
            *stop = YES;
        }
        // current value is smaller than the new value,
        // keep going
    }];
    if (index < 0) {
        return;
    }
    // insert new value before the bigger one
    [_priorities insertObject:@(priority) atIndex:index];
}

- (DIMMessageWrapper *)nextTask {
    __block DIMMessageWrapper *target = nil;
    @synchronized (self) {
        [_priorities enumerateObjectsUsingBlock:^(NSNumber *prior, NSUInteger idx, BOOL *stop) {
            // get first task
            WrapperList *array = [_fleets objectForKey:prior];
            if ([array count] > 0) {
                target = [array firstObject];
                [array removeObjectAtIndex:0];
                *stop = YES;
            }
        }];
    }
    return target;
}

- (void)purge {
    @synchronized (self) {
        OKArrayList<NSNumber *> *emptyPositions = [[OKArrayList alloc] init];
        [_priorities enumerateObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(NSNumber *prior, NSUInteger idx, BOOL *stop) {
            WrapperList *array = [_fleets objectForKey:prior];
            if (!array) {
                // this priority is empty
                [emptyPositions addObject:@(idx)];
            } else if ([array count] == 0) {
                // this priority is empty
                [_fleets removeObjectForKey:prior];
                [emptyPositions addObject:@(idx)];
            }
        }];
        [emptyPositions enumerateObjectsWithOptions:NSEnumerationReverse
                                  usingBlock:^(NSNumber *pos, NSUInteger idx, BOOL *stop) {
            [_priorities removeObjectAtIndex:[pos integerValue]];
        }];
    }
}

@end

@implementation DIMMessageQueue (Creation)

+ (instancetype)queue {
    return [[DIMMessageQueue alloc] init];
}

@end
