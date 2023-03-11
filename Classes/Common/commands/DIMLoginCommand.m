// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
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
//  DIMLoginCommand.m
//  DIMSDK
//
//  Created by Albert Moky on 2020/4/14.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import "DIMLoginCommand.h"

@implementation DIMLoginCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    if (self = [self initWithCommandName:DIMCommand_Login]) {
        // ID
        if (ID) {
            [self setObject:[ID string] forKey:@"ID"];
        }
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMLoginCommand *content = [super copyWithZone:zone];
    if (content) {
        //
    }
    return content;
}

#pragma mark Client Info

- (id<MKMID>)ID {
    id string = [self objectForKey:@"ID"];
    return MKMIDParse(string);
}

- (NSString *)device {
    return [self objectForKey:@"device"];
}
- (void)setDevice:(NSString *)device {
    if (device) {
        [self setObject:device forKey:@"device"];
    } else {
        [self removeObjectForKey:@"device"];
    }
}

- (NSString *)agent {
    return [self objectForKey:@"agent"];
}
- (void)setAgent:(NSString *)agent {
    if (agent) {
        [self setObject:agent forKey:@"agent"];
    } else {
        [self removeObjectForKey:@"agent"];
    }
}

#pragma mark Server Info

- (NSDictionary *)stationInfo {
    return [self objectForKey:@"station"];
}
- (void)setStationInfo:(NSDictionary *)stationInfo {
    if (stationInfo) {
        [self setObject:stationInfo forKey:@"station"];
    } else {
        [self removeObjectForKey:@"station"];
    }
}
- (void)copyStationInfo:(DIMStation *)station {
    id<MKMID> ID = station.ID;
    NSString *host = station.host;
    UInt32 port = station.port;
    if (!ID || [host length] == 0) {
        NSAssert(!station, @"station error: %@", station);
        return;
    }
    if (port == 0) {
        port = 9394;
    }
    [self setStationInfo:@{
        @"ID"  : [ID string],
        @"host": host,
        @"port": @(port),
    }];
}

- (NSDictionary *)providerInfo {
    return [self objectForKey:@"provider"];
}
- (void)setProviderInfo:(NSDictionary *)providerInfo {
    if (providerInfo) {
        [self setObject:providerInfo forKey:@"provider"];
    } else {
        [self removeObjectForKey:@"provider"];
    }
}
- (void)copyProviderInfo:(DIMServiceProvider *)provider {
    id<MKMID> ID = provider.ID;
    if (!ID) {
        NSAssert(!provider, @"SP error: %@", provider);
        return;
    }
    [self setProviderInfo:@{
        @"ID"  : [ID string],
    }];
}

@end
