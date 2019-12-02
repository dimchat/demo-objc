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
//  DIMMuteCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMMuteCommand.h"

@interface DIMMuteCommand () {
    
    NSMutableArray *_list;
}

@end

@implementation DIMMuteCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _list = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _list = nil;
    }
    return self;
}

- (instancetype)initWithList:(nullable NSArray<DIMID *> *)muteList {
    if (self = [self initWithHistoryCommand:DIMCommand_Mute]) {
        // mute-list
        if (muteList) {
            _list = [muteList mutableCopy];
            [_storeDictionary setObject:_list forKey:@"list"];
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
        // create mute-list
        _list = [[NSMutableArray alloc] init];
        [_storeDictionary setObject:_list forKey:@"list"];
    } else if ([_list containsObject:ID]) {
        NSAssert(false, @"ID already exists: %@", ID);
        return;
    }
    [_list addObject:ID];
}

- (void)removeID:(DIMID *)ID {
    NSAssert(_list, @"mute-list not set yet");
    [_list removeObject:ID];
}

@end
