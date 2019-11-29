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
//  DIMBlockCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMBlockCommand.h"

@interface DIMBlockCommand () {
    
    NSMutableArray *_list;
}

@end

@implementation DIMBlockCommand

- (instancetype)initWithList:(nullable NSArray<DIMID *> *)blockList {
    if (self = [super initWithHistoryCommand:DIMCommand_Block]) {
        // block-list
        if (blockList) {
            _list = [blockList mutableCopy];
            [_storeDictionary setObject:_list forKey:@"list"];
        } else {
            _list = nil;
        }
    }
    return self;
}

- (nullable NSArray<NSString *> *)list {
    if (!_list) {
        NSObject *array = [_storeDictionary objectForKey:@"list"];
        if (![array isKindOfClass:[NSMutableArray class]]) {
            _list = [array mutableCopy];
        }
    }
    return _list;
}

- (void)addID:(DIMID *)ID {
    if (![self list]) {
        // create block-list
        _list = [[NSMutableArray alloc] init];
        [_storeDictionary setObject:_list forKey:@"list"];
    } else if ([_list containsObject:ID]) {
        NSAssert(false, @"ID already exists: %@", ID);
        return;
    }
    [_list addObject:ID];
}

- (void)removeID:(DIMID *)ID {
    NSAssert(_list, @"block-list not set yet");
    [_list removeObject:ID];
}

@end
