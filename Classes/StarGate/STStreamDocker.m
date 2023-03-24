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
//  STStreamDocker.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamArrival.h"
#import "STStreamDeparture.h"

#import "STStreamDocker.h"

static NSString *PING = @"PING";
static NSString *PONG = @"PONG";
static NSString *NOOP = @"NOOP";

static inline NSData *utf8_encode(NSString *string) {
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@implementation STPlainDocker

- (id<STArrival>)createArrivalWithData:(NSData *)pack {
    return [[STPlainArrival alloc] initWithData:pack];
}

- (id<STDeparture>)createDepartureWithData:(NSData *)pack priority:(NSInteger)prior {
    return [[STPlainDeparture alloc] initWithData:pack priority:prior];
}

// Override
- (id<STArrival>)arrivalWithData:(NSData *)data {
    if ([data length] == 0) {
        return nil;
    }
    return [self createArrivalWithData:data];
}

// Override
- (id<STArrival>)checkArrival:(id<STArrival>)income {
    NSAssert([income isKindOfClass:[STPlainArrival class]], @"arrival ship error: %@", income);
    NSData *data = [(STPlainArrival *)income package];
    if ([data length] == 4) {
        if ([data isEqualToData:utf8_encode(PING)]) {
            // PING -> PONG
            [self sendData:utf8_encode(PONG)
                  priority:STDeparturePrioritySlower];
            return nil;
        } else if ([data isEqualToData:utf8_encode(PONG)] ||
                   [data isEqualToData:utf8_encode(NOOP)]) {
            // ignore
            return nil;
        }
    }
    return income;
}

//
//  Sending
//

- (BOOL)sendData:(NSData *)payload priority:(NSInteger)prior {
    // sending payload with priority
    id<STDeparture> ship = [self createDepartureWithData:payload priority:prior];
    return [self sendShip:ship];
}

// Override
- (BOOL)sendData:(NSData *)payload {
    return [self sendData:payload priority:STDeparturePriorityNormal];
}

// Override
- (void)heartbeat {
    [self sendData:utf8_encode(PING) priority:STDeparturePrioritySlower];
}

@end

@implementation STStreamDocker

// Override
- (void)processReceivedData:(NSData *)data {
    // TODO: the cached data maybe contain sticky packages,
    //       so we need to process them circularly here
    [super processReceivedData:data];
}

// Override
- (id<STArrival>)checkArrival:(id<STArrival>)income {
    // TODO: check sticky data
    return [super checkArrival:income];
}

// Override
- (id<STArrival>)createArrivalWithData:(NSData *)pack {
    return [[STStreamArrival alloc] initWithData:pack];
}

// Override
- (id<STDeparture>)createDepartureWithData:(NSData *)pack priority:(NSInteger)prior {
    // TODO: check pack type?
    return [[STStreamDeparture alloc] initWithData:pack priority:prior];
}

- (id<STDeparture>)departureByPackData:(NSData *)payload priority:(NSInteger)prior {
    // packData
    return [self createDepartureWithData:payload priority:prior];
}

@end
