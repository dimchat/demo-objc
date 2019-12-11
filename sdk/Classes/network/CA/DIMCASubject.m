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
//  DIMCASubject.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCASubject.h"

@implementation DIMCASubject

+ (instancetype)subjectWithSubject:(id)subject {
    if ([subject isKindOfClass:[DIMCASubject class]]) {
        return subject;
    } else if ([subject isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:subject];
    } else {
        NSAssert(!subject, @"unexpected subject: %@", subject);
        return nil;
    }
}

#pragma mark 'C' for Country

- (NSString *)country {
    return [_storeDictionary objectForKey:@"C"];
}

- (void)setCountry:(NSString *)country {
    if (country) {
        [_storeDictionary setObject:country forKey:@"C"];
    } else {
        [_storeDictionary removeObjectForKey:@"C"];
    }
}

#pragma mark 'ST' for State/Province

- (NSString *)state {
    return [_storeDictionary objectForKey:@"ST"];
}

- (void)setState:(NSString *)state {
    if (state) {
        [_storeDictionary setObject:state forKey:@"ST"];
    } else {
        [_storeDictionary removeObjectForKey:@"ST"];
    }
}

#pragma mark 'L' for Locality

- (NSString *)locality {
    return [_storeDictionary objectForKey:@"L"];
}

- (void)setLocality:(NSString *)locality {
    if (locality) {
        [_storeDictionary setObject:locality forKey:@"L"];
    } else {
        [_storeDictionary removeObjectForKey:@"L"];
    }
}

#pragma mark 'O' for Organization

- (NSString *)organization {
    return [_storeDictionary objectForKey:@"O"];
}

- (void)setOrganization:(NSString *)organization {
    if (organization) {
        [_storeDictionary setObject:organization forKey:@"O"];
    } else {
        [_storeDictionary removeObjectForKey:@"O"];
    }
}

#pragma mark 'OU' for Organization Unit

- (NSString *)organizationUnit {
    return [_storeDictionary objectForKey:@"OU"];
}

- (void)setOrganizationUnit:(NSString *)organizationUnit {
    if (organizationUnit) {
        [_storeDictionary setObject:organizationUnit forKey:@"OU"];
    } else {
        [_storeDictionary removeObjectForKey:@"OU"];
    }
}

#pragma mark 'CN' for Common Name

- (NSString *)commonName {
    return [_storeDictionary objectForKey:@"CN"];
}

- (void)setCommonName:(NSString *)commonName {
    if (commonName) {
        [_storeDictionary setObject:commonName forKey:@"CN"];
    } else {
        [_storeDictionary removeObjectForKey:@"CN"];
    }
}

@end
