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
//  DIMChatroom.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMChatroom.h"

@implementation DIMChatroom

#pragma mark Admins of Chatroom

- (NSArray<DIMID *> *)admins {
    NSAssert(self.dataSource, @"chatroom data source not set yet");
    NSArray *list = [self.dataSource adminsOfChatroom:_ID];
    return [list copy];
}

- (BOOL)existsAdmin:(DIMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(self.dataSource, @"chatroom data source not set yet");
    NSArray<DIMID *> *admins = [self admins];
    NSInteger count = [admins count];
    if (count <= 0) {
        return NO;
    }
    DIMID *admin;
    while (--count >= 0) {
        admin = [admins objectAtIndex:count];
        if ([admin isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
