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
//  DIMSessionDBI.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMSessionDBI.h"

static id<MKMID> s_gsp = nil;

id<MKMID> DIMGSP(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_gsp = [[MKMID alloc] initWithString:@"gsp@everywhere"
                                         name:@"gsp"
                                      address:MKMAnywhere()
                                     terminal:nil];
    });
    return s_gsp;
}

@interface DIMProviderInfo ()

@property (strong, nonatomic) id<MKMID> ID;

@end

@implementation DIMProviderInfo

- (instancetype)initWithID:(id<MKMID>)PID chosen:(NSInteger)order {
    if (self = [self init]) {
        self.ID = PID;
        self.chosen = order;
    }
    return self;
}

+ (instancetype)providerWithID:(id<MKMID>)PID chosen:(NSInteger)order {
    return [[DIMProviderInfo alloc] initWithID:PID chosen:order];
}

+ (NSArray<DIMProviderInfo *> *)convert:(NSArray<NSDictionary *> *)array {
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:array.count];
    id<MKMID> PID;
    NSInteger chosen;
    for (NSDictionary *info in array) {
        PID = MKMIDParse([info objectForKey:@"ID"]);
        chosen = MKMConverterGetInteger([info objectForKey:@"chosen"], 0);
        if (!PID) {
            // SP ID error
            NSAssert(false, @"provider ID error: %@", info);
            continue;
        }
        [providers addObject:[DIMProviderInfo providerWithID:PID chosen:chosen]];
    }
    return providers;
}

+ (NSArray<NSDictionary *> *)revert:(NSArray<DIMProviderInfo *> *)providers {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:providers.count];
    for (DIMProviderInfo *info in providers) {
        [array addObject:@{
            @"ID": [info.ID string],
            @"chosen": @(info.chosen),
        }];
    }
    return array;
}

@end

@interface DIMStationInfo ()

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt16 port;

@end

@implementation DIMStationInfo

- (instancetype)initWithID:(nullable id<MKMID>)SID
                    chosen:(NSInteger)order
                      host:(NSString *)IP
                      port:(UInt16)port
                  provider:(nullable id<MKMID>)PID {
    if (self = [self init]) {
        self.ID = SID;
        self.chosen = order;
        self.host = IP;
        self.port = port;
        self.provider = PID;
    }
    return self;
}

+ (instancetype)stationWithID:(nullable id<MKMID>)SID
                       chosen:(NSInteger)order
                         host:(NSString *)IP
                         port:(UInt16)port
                     provider:(nullable id<MKMID>)PID {
    return [[DIMStationInfo alloc] initWithID:SID
                                       chosen:order
                                         host:IP
                                         port:port
                                     provider:PID];
}

+ (NSArray<DIMStationInfo *> *)convert:(NSArray<NSDictionary *> *)array {
    NSMutableArray *stations = [[NSMutableArray alloc] initWithCapacity:array.count];
    id<MKMID> SID;
    NSInteger chosen;
    NSString *IP;
    UInt16 port;
    id<MKMID> PID;
    for (NSDictionary *info in array) {
        SID = MKMIDParse([info objectForKey:@"ID"]);
        chosen = MKMConverterGetInteger([info objectForKey:@"chosen"], 0);
        IP = MKMConverterGetString([info objectForKey:@"host"], nil);
        port = MKMConverterGetUnsignedShort([info objectForKey:@"port"], 0);
        PID = MKMIDParse([info objectForKey:@"provider"]);
        if (!IP || port == 0/* || !PID*/) {
            // SP ID error
            NSAssert(false, @"station info error: %@", info);
            continue;
        }
        [stations addObject:[DIMStationInfo stationWithID:SID
                                                   chosen:chosen
                                                     host:IP
                                                     port:port
                                                 provider:PID]];
    }
    return stations;
}

+ (NSArray<NSDictionary *> *)revert:(NSArray<DIMStationInfo *> *)stations {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:stations.count];
    for (DIMStationInfo *info in stations) {
        [array addObject:@{
            @"ID": [info.ID string],
            @"chosen": @(info.chosen),
            @"host": [info host],
            @"port": @(info.port),
            @"provider": [info.provider string],
        }];
    }
    return array;
}

@end
