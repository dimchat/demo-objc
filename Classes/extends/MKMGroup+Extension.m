// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
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
//  MKMGroup+Extension.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/18.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"
#import "MKMGroup+Extension.h"

@implementation MKMGroup (Extension)

- (NSArray<DIMID *> *)assistants {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray *list = [facebook assistantsOfGroup:self.ID];
    return [list copy];
}

- (BOOL)isFounder:(DIMID *)ID {
    DIMID *founder = [self founder];
    if (founder) {
        return [founder isEqual:ID];
    } else {
        DIMMeta *meta = [self meta];
        DIMPublicKey *PK = [DIMMetaForID(ID) key];
        //NSAssert(PK, @"failed to get meta for ID: %@", ID);
        return [meta matchPublicKey:PK];
    }
}

- (BOOL)isOwner:(DIMID *)ID {
    if (self.ID.type == MKMNetwork_Polylogue) {
        return [self isFounder:ID];
    }
    // check owner
    DIMID *owner = [self owner];
    return [owner isEqual:ID];
}

- (BOOL)existsAssistant:(DIMID *)ID {
    NSArray<DIMID *> *assistants = [self assistants];
    return [assistants containsObject:ID];
}

- (BOOL)existsMember:(DIMID *)ID {
    // check broadcast ID
    if ([_ID isBroadcast]) {
        // anyone user is a member of the broadcast group 'everyone@everywhere'
        return MKMNetwork_IsUser([ID type]);
    }
    // check all member(s)
    NSArray<DIMID *> *members = [self members];
    for (DIMID *item in members) {
        if ([item isEqual:ID]) {
            return YES;
        }
    }
    // check owner
    return [self isOwner:ID];
}

@end
