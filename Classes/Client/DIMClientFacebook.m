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
//  DIMClientFacebook.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/13.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "DIMRegister.h"

#import "DIMClientFacebook.h"

static DIMAddressNameServer *_ans = nil;
static id<MKMIDFactory> _idFactory = nil;

@interface IDFactory : NSObject <MKMIDFactory>

@end

@implementation IDFactory

- (nonnull id<MKMID>)createID:(nullable NSString *)name
                      address:(id<MKMAddress>)address
                     terminal:(nullable NSString *)location {
    return [_idFactory createID:name address:address terminal:location];
}

- (nonnull id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta
                                   type:(MKMEntityType)network
                               terminal:(nullable NSString *)location {
    return [_idFactory generateIDWithMeta:meta type:network terminal:location];
}

- (nullable id<MKMID>)parseID:(nonnull NSString *)identifier {
    // try ANS record
    id<MKMID> ID = [_ans getID:identifier];
    if (ID) {
        return ID;
    }
    // parse by original factory
    return [_idFactory parseID:identifier];
}

@end

@implementation DIMClientFacebook

- (NSString *)nameForID:(id<MKMID>)ID {
    // get name from document
    id<MKMDocument> doc = [self documentForID:ID type:@"*"];
    if (doc) {
        NSString *name = [doc name];
        if ([name length] > 0) {
            return name;
        }
    }
    // get name from ID
    return [MKMAnonymous name:ID];
}

+ (DIMAddressNameServer *)ans {
    return _ans;
}

+ (void)setANS:(DIMAddressNameServer *)ans {
    _ans = ans;
}

+ (void)prepare {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // load plugins
        [DIMRegister prepare];
        
        _idFactory = MKMIDGetFactory();
        MKMIDSetFactory([[IDFactory alloc] init]);
        
    });
}

@end

@implementation DIMFacebook (Membership)

- (BOOL)isFounder:(id<MKMID>)member group:(id<MKMID>)group {
    return [self group:group isFounder:member];
}

- (BOOL)isOwner:(id<MKMID>)member group:(id<MKMID>)group {
    return [self group:group isOwner:member];
}

@end
