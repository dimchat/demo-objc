// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  MKMAnonymous.m
//  DIMClient
//
//  Created by Albert Moky on 2021/2/18.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "MKMAnonymous.h"

static inline UInt32 user_number(NSData *cc) {
    NSUInteger len = cc.length;
    const UInt8 *bytes = cc.bytes;
    return
    (bytes[len-4] & 0xFF) << 24 |
    (bytes[len-3] & 0xFF) << 16 |
    (bytes[len-2] & 0xFF) << 8 |
    (bytes[len-1] & 0xFF);
}

static inline UInt32 btc_number(NSString *address) {
    NSData *data = MKMBase58Decode(address);
    return user_number(data);
}
static inline UInt32 eth_number(NSString *address) {
    NSData *data = MKMHexDecode([address substringFromIndex:2]);
    return user_number(data);
}

static inline NSString *name_from_type(MKMEntityType network) {
    if (MKMNetwork_IsBot(network)) {
        return @"Bot";
    }
    if (MKMNetwork_IsStation(network)) {
        return @"Station";
    }
    if (MKMNetwork_IsProvider(network)) {
        return @"SP";
    }
    if (MKMEntity_IsUser(network)) {
        return @"User";
    }
    if (MKMEntity_IsGroup(network)) {
        return @"Group";
    }
    return @"Unknown";
}

@implementation MKMAnonymous

+ (NSString *)name:(id<MKMID>)ID {
    NSString *string = ID.name;
    if (string.length == 0) {
        string = name_from_type(ID.type);
    }
    NSString *number = [self numberString:ID.address];
    return [NSString stringWithFormat:@"%@ (%@)", string, number];
}

+ (UInt32)number:(id<MKMAddress>)address {
    if ([address isKindOfClass:[MKMAddressBTC class]]) {
        return btc_number(address.string);
    }
    if ([address isKindOfClass:[MKMAddressETH class]]) {
        return eth_number(address.string);
    }
    NSAssert(false, @"address error: %@", address);
    return 0;
}

+ (NSString *)numberString:(id<MKMAddress>)address {
    UInt32 number = [self number:address];
    NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"%010u", number];
    if ([string length] == 10) {
        [string insertString:@"-" atIndex:6];
        [string insertString:@"-" atIndex:3];
    }
    return string;
}

@end
