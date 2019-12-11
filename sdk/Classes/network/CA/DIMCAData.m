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
//  DIMCAData.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCASubject.h"
#import "DIMCAValidity.h"

#import "DIMCAData.h"

@implementation DIMCAData

+ (instancetype)dataWithData:(id)data {
    if ([data isKindOfClass:[DIMCAData class]]) {
        return data;
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:data];
    } else {
        NSAssert(!data, @"unexpected data: %@", data);
        return nil;
    }
}

#pragma mark Issuer

- (DIMCASubject *)issuer {
    DIMCASubject *sub = [_storeDictionary objectForKey:@"Issuer"];
    return [DIMCASubject subjectWithSubject:sub];
}

- (void)setIssuer:(DIMCASubject *)issuer {
    if (issuer) {
        [_storeDictionary setObject:issuer forKey:@"Issuer"];
    } else {
        [_storeDictionary removeObjectForKey:@"Issuer"];
    }
}

#pragma mark Validity

- (DIMCAValidity *)validity {
    DIMCAValidity *val = [_storeDictionary objectForKey:@"Validity"];
    return [DIMCAValidity validityWithValidity:val];
}

- (void)setValidity:(DIMCAValidity *)validity {
    if (validity) {
        [_storeDictionary setObject:validity forKey:@"Validity"];
    } else {
        [_storeDictionary removeObjectForKey:@"Validity"];
    }
}

#pragma mark Subject

- (DIMCASubject *)subject {
    DIMCASubject *sub = [_storeDictionary objectForKey:@"Subject"];
    return [DIMCASubject subjectWithSubject:sub];
}

- (void)setSubject:(DIMCASubject *)subject {
    if (subject) {
        [_storeDictionary setObject:subject forKey:@"Subject"];
    } else {
        [_storeDictionary removeObjectForKey:@"Subject"];
    }
}

#pragma mark PublicKey

- (DIMPublicKey *)publicKey {
    DIMPublicKey *PK = [_storeDictionary objectForKey:@"PublicKey"];
    return MKMPublicKeyFromDictionary(PK);
}

- (void)setPublicKey:(DIMPublicKey *)publicKey {
    if (publicKey) {
        [_storeDictionary setObject:publicKey forKey:@"PublicKey"];
    } else {
        [_storeDictionary removeObjectForKey:@"PublicKey"];
    }
}

@end
