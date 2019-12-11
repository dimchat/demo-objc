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
//  DIMCertificateAuthority.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMCAData.h"

#import "DIMCertificateAuthority.h"

@implementation DIMCertificateAuthority

+ (instancetype)caWithCA:(id)ca {
    if ([ca isKindOfClass:[DIMCertificateAuthority class]]) {
        return ca;
    } else if ([ca isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:ca];
    } else {
        NSAssert(!ca, @"unexpected CA: %@", ca);
        return nil;
    }
}

#pragma mark Version

- (NSUInteger)version {
    NSNumber *num = [_storeDictionary objectForKey:@"Version"];
    return [num unsignedIntegerValue];
}

- (void)setVersion:(NSUInteger)version {
    [_storeDictionary setObject:@(version) forKey:@"Version"];
}

#pragma mark SerialNumber

- (NSString *)serialNumber {
    return [_storeDictionary objectForKey:@"SerialNumber"];
}

- (void)setSerialNumber:(NSString *)serialNumber {
    if (serialNumber) {
        [_storeDictionary setObject:serialNumber forKey:@"SerialNumber"];
    } else {
        [_storeDictionary removeObjectForKey:@"SerialNumber"];
    }
}

#pragma mark Info (CAData)

- (DIMCAData *)info {
    NSString *json = [_storeDictionary objectForKey:@"Info"];
    return [DIMCAData dataWithData:json];
}

- (void)setInfo:(DIMCAData *)info {
    if (info) {
        NSString *json = [info jsonString];
        [_storeDictionary setObject:json forKey:@"Info"];
    } else {
        [_storeDictionary removeObjectForKey:@"Info"];
    }
}

#pragma mark Signature

- (NSData *)signature {
    NSString *encode = [_storeDictionary objectForKey:@"Signature"];
    return [encode base64Decode];
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        NSString *encode = [signature base64Encode];
        [_storeDictionary setObject:encode forKey:@"Signature"];
    } else {
        [_storeDictionary removeObjectForKey:@"Signature"];
    }
}

#pragma mark Extensions

- (NSMutableDictionary *)extensions {
    return [_storeDictionary objectForKey:@"Extensions"];
}

- (void)setExtraValue:(id)value forKey:(NSString *)key {
    NSAssert(value, @"extra value cannot be empty");
    NSMutableDictionary *ext = [_storeDictionary objectForKey:@"Extensions"];
    if (!ext) {
        ext = [[NSMutableDictionary alloc] init];
        [_storeDictionary setObject:ext forKey:@"Extensions"];
    }
    if (value) {
        [ext setObject:value forKey:key];
    }
}

#pragma mark - Verify

- (BOOL)verifyWithPublicKey:(DIMPublicKey *)PK {
    NSString *json = [_storeDictionary objectForKey:@"Info"];
    return [PK verify:[json data] withSignature:self.signature];
}

@end
