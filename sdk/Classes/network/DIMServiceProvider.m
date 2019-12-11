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
//  DIMServiceProvider.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

/* designated initializer */
- (instancetype)initWithID:(DIMID *)ID {
    if (self = [super initWithID:ID]) {
        _CA = nil;
        _home = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = MKMIDFromString([dict objectForKey:@"ID"]);
//    // founder
//    DIMID *founder = [dict objectForKey:@"founder"];
//    founder = MKMIDFromString(founder);
//    // owner
//    DIMID *owner = [dict objectForKey:@"owner"];
//    owner = MKMIDFromString(owner);
    
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    // home
    id home = [dict objectForKey:@"home"];
    if ([home isKindOfClass:[NSString class]]) {
        home = [NSURL URLWithString:home];
    }
    
    if (self = [self initWithID:ID]) {
        _CA = CA;
        _home = home;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMServiceProvider *SP = [super copyWithZone:zone];
    if (SP) {
        SP.CA = _CA;
        SP.home = _home;
    }
    return SP;
}

- (NSString *)name {
    DIMCASubject *subject = self.CA.info.subject;
    if (subject.commonName) {
        return subject.commonName;
    } else if (subject.organization) {
        return subject.organization;
    } else {
        return [super name];
    }
}

- (DIMPublicKey *)publicKey {
    return self.CA.info.publicKey;
}

#pragma mark Station

- (BOOL)verifyStation:(DIMStation *)server {
    DIMCertificateAuthority *CA = server.CA;
    return [CA verifyWithPublicKey:self.publicKey];
}

@end
