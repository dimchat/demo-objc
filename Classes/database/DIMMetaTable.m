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
//  DIMMetaTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMClientConstants.h"

#import "DIMMetaTable.h"

@interface DIMMetaTable () {

    NSMutableDictionary<id<MKMID>, id<MKMMeta>> *_caches;
    
    id<MKMMeta> _empty;
}

@end

@implementation DIMMetaTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[NSMutableDictionary alloc] init];
        
        _empty = [[MKMMeta alloc] initWithDictionary:@{}];
    }
    return self;
}

/**
 *  Get meta filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/meta.plist"
 */
- (NSString *)_filePathWithID:(id<MKMID>)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:[ID.address string]];
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    // 1. try from memory cache
    id<MKMMeta> meta = [_caches objectForKey:ID];
    if (!meta) {
        // 2. try from local storage
        NSString *path = [self _filePathWithID:ID];
        NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
        if (dict) {
            NSLog(@"meta from: %@", path);
            meta = MKMMetaParse(dict);
        }
        if (!meta) {
            // 2.1. place an empty meta for cache
            meta = _empty;
        }
        // 3. store into memory cache
        [_caches setObject:meta forKey:ID];
    }
    if (meta == _empty) {
        NSLog(@"meta not found: %@", ID);
        return nil;
    }
    return meta;
}

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    if (!MKMMetaMatchID(ID, meta)) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    // 0. check duplicate record
    id<MKMMeta> old = [self metaForID:ID];
    if (old) {
        // meta won't change, no need to update
        return YES;
    }
    // 1. store into memory cache
    [_caches setObject:meta forKey:ID];
    // 2. save into local storage
    NSString *path = [self _filePathWithID:ID];
    NSLog(@"saving meta into: %@ -> %@", ID, path);
    return [self dictionary:meta.dictionary writeToBinaryFile:path];
}

@end
