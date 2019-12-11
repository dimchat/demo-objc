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
//  DIMStation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Compare.h"
#import "NSObject+JsON.h"

#import "DIMServiceProvider.h"

#import "DIMStation.h"

@interface DIMStation ()

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt32 port;

@end

@implementation DIMStation

/* designated initializer */
- (instancetype)initWithID:(DIMID *)ID {
    if (self = [super initWithID:ID]) {
        _host = nil;
        _port = 9394;
        _SP = nil;
        _CA = nil;
        _delegate = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = MKMIDFromString([dict objectForKey:@"ID"]);
//    // public key
//    DIMPublicKey *PK = [dict objectForKey:@"publicKey"];
//    if (!PK) {
//        PK = [dict objectForKey:@"PK"];
//        if (!PK) {
//            // get from meta.key
//            DIMMeta *meta = [dict objectForKey:@"meta"];
//            if (meta) {
//                meta = MKMMetaFromDictionary(meta);
//                PK = meta.key;
//            }
//        }
//    }
//    PK = MKMPublicKeyFromDictionary(PK);
    
    // host
    NSString *host = [dict objectForKey:@"host"];
    // port
    NSNumber *port = [dict objectForKey:@"port"];
    if (port == nil) {
        port = @(9394);
    }
    // SP
    id SP = [dict objectForKey:@"SP"];
    if ([SP isKindOfClass:[NSDictionary class]]) {
        SP = [[DIMServiceProvider alloc] initWithDictionary:SP];
    }
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    
//    if (!PK) {
//        // get from CA.info.publicKey
//        PK = CA.info.publicKey;
//    }
    // TODO: save public key for the Station
    
    if (self = [self initWithID:ID
                           host:host
                           port:[port unsignedIntValue]]) {
        _SP = SP;
        _CA = CA;
    }
    return self;
}

- (instancetype)initWithID:(DIMID *)ID
                      host:(NSString *)IP
                      port:(UInt32)port {
    if (self = [self initWithID:ID]) {
        _host = IP;
        _port = port;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMStation *server = [super copyWithZone:zone];
    if (server) {
        server.host = _host;
        server.port = _port;
        server.SP = _SP;
        server.CA = _CA;
        server.delegate = _delegate;
    }
    return server;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSData *data = [desc data];
    NSDictionary *dict = [data jsonDictionary];
    NSMutableDictionary *mDict = [dict mutableCopy];
    [mDict setObject:self.host forKey:@"host"];
    [mDict setObject:@(self.port) forKey:@"port"];
    return [mDict jsonString];
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        YES;
    }
    NSAssert([object isKindOfClass:[DIMStation class]], @"error: %@", object);
    DIMStation *server = (DIMStation *)object;
    if (![server.host isEqualToString:_host]) {
        return NO;
    }
    if (server.port != _port) {
        return NO;
    }
    // others?
    return YES;
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

- (NSURL *)home {
    return self.SP.home;
}

- (NSData *)encrypt:(NSData *)plaintext {
    // 1. get key for encryption from CA.info.publicKey
    DIMPublicKey *key = [self publicKey];
    if (key == nil) {
        // 2. get key for encryption from meta
        DIMMeta *meta = [self meta];
        // NOTICE: meta.key will never changed,
        //         so use profile.key to encrypt is the better way
        key = (DIMPublicKey *)[meta key];
    }
    // 3. encrypt with profile.key
    return [(id<MKMEncryptKey>)key encrypt:plaintext];
}

@end
