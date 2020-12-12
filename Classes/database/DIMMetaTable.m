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

#import "DIMMetaTable.h"

typedef NSMutableDictionary<id<MKMID>, id<MKMMeta>> CacheTableM;

@interface DIMMetaTable () {

    CacheTableM *_caches;
    
    id<MKMMeta>_emptyMeta;
}

@end

@implementation DIMMetaTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
        
        _emptyMeta = [[MKMMeta alloc] initWithDictionary:@{}];
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
    return [self _filePathWithAddress:ID.address];
}
- (NSString *)_filePathWithAddress:(id<MKMAddress>)address {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:address.string];
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

- (BOOL)_cacheMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    [_caches setObject:meta forKey:ID];
    return YES;
}

- (nullable id<MKMMeta>)_loadMetaForID:(id<MKMID>)ID {
    NSString *path = [self _filePathWithID:ID];
    NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
    if (!dict) {
        NSLog(@"meta not found: %@", path);
        return nil;
    }
    NSLog(@"meta from: %@", path);
    return MKMMetaFromDictionary(dict);
}

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    id<MKMMeta>meta = [_caches objectForKey:ID];
    if (meta) {
        if (meta == _emptyMeta) {
            NSLog(@"meta not found: %@", ID);
            return nil;
        }
    } else {
        // first access, try to load from local storage
        meta = [self _loadMetaForID:ID];
        if (meta) {
            // no need to check meta again
            [_caches setObject:meta forKey:ID];
        } else {
            // place an empty meta for cache
            [_caches setObject:_emptyMeta forKey:ID];
        }
    }
    return meta;
}

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    if (![self _cacheMeta:meta forID:ID]) {
        NSAssert(false, @"failed to cache meta for ID: %@, %@", ID, meta);
        return NO;
    }
    NSString *path = [self _filePathWithID:ID];
    if ([self fileExistsAtPath:path]) {
        NSLog(@"meta already exists: %@", path);
        return YES;
    }
    NSLog(@"saving meta into: %@", path);
    return [self dictionary:meta.dictionary writeToBinaryFile:path];
}

@end
