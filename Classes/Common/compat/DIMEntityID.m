// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  DIMEntityID.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import "DIMNetworkID.h"
#import "DIMAddressBTC.h"

#import "DIMEntityID.h"

@interface EntityID : MKMID

@end

@implementation EntityID

// Override
- (MKMEntityType)type {
    MKMNetworkID network = [self.address type];
    // compatible with MKM 0.9.*
    return MKMEntityTypeFromNetworkID(network);
}

@end

#pragma mark -

@interface EntityIDFactory : DIMIDFactory

@end

@implementation EntityIDFactory

// Override
- (id<MKMID>)newID:(NSString *)identifier
              name:(nullable NSString *)seed
           address:(id<MKMAddress>)main
          terminal:(nullable NSString *)loc {
    // override for customized ID
    return [[EntityID alloc] initWithString:identifier
                                       name:seed
                                    address:main
                                   terminal:loc];
}

// Override
- (nullable id<MKMID>)parse:(NSString *)identifier {
    NSComparisonResult res;
    NSUInteger len = [identifier length];
    if (len == 15) {
        // "anyone@anywhere"
        res = [MKMAnyone().string caseInsensitiveCompare:identifier];
        if (res == NSOrderedSame) {
            return MKMAnyone();
        }
    } else if (len == 19) {
        // "everyone@everywhere"
        // "stations@everywhere"
        res = [MKMEveryone().string caseInsensitiveCompare:identifier];
        if (res == NSOrderedSame) {
            return MKMEveryone();
        }
    } else if (len == 13) {
        // "moky@anywhere"
        res = [MKMFounder().string caseInsensitiveCompare:identifier];
        if (res == NSOrderedSame) {
            return MKMFounder();
        }
    }
    return [super parse:identifier];
}

@end

#pragma mark -

@interface CompatibleAddressFactory : DIMAddressFactory

@end

@implementation CompatibleAddressFactory

- (id<MKMAddress>)createAddress:(NSString *)address {
    NSComparisonResult res;
    NSUInteger len = [address length];
    if (len == 8) {
        // "anywhere"
        res = [MKMAnywhere().string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMAnywhere();
        }
    } else if (len == 10) {
        // "everywhere"
        res = [MKMEverywhere().string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMEverywhere();
        }
    }
    id<MKMAddress> addr;
    if (len == 42) {
        // ETH address
        addr = [MKMAddressETH parse:address];
    } else if (26 <= len && len <= 35) {
        // try BTC address
        addr = [DIMAddressBTC parse:address];
    }
    NSAssert(addr, @"invalid address: %@", address);
    return addr;
}

@end

#pragma mark -

void DIMRegisterEntityIDFactory(void) {
    EntityIDFactory *factory = [[EntityIDFactory alloc] init];
    MKMIDSetFactory(factory);
}

void DIMRegisterCompatibleAddressFactory(void) {
    CompatibleAddressFactory *factory = [[CompatibleAddressFactory alloc] init];
    MKMAddressSetFactory(factory);
}
