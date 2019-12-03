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
//  DIMAddressNameTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/13.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"

#import "DIMAddressNameTable.h"

typedef NSMutableDictionary<NSString *, DIMID *> CacheTableM;

@interface DIMAddressNameTable () {
    
    CacheTableM *_caches;
}

@property (readonly, strong, nonatomic) CacheTableM *caches;

@end

@implementation DIMAddressNameTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = nil;
    }
    return self;
}

- (CacheTableM *)caches {
    if (!_caches) {
        _caches = [self _loadRecords];
    }
    return _caches;
}

/**
 *  Get ANS filepath in Documents Directory
 *
 * @return "Documents/.dim/ans.plist"
 */
- (NSString *)_ansFilePath {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".dim"];
    return [dir stringByAppendingPathComponent:@"ans.plist"];
}

- (CacheTableM *)_loadRecords {
    CacheTableM *caches = [[CacheTableM alloc] init];
    DIMID *ID;
    NSString *path = [self _ansFilePath];
    NSLog(@"loading ANS records from: %@", path);
    NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
    for (NSString *name in dict) {
        ID = DIMIDWithString([dict objectForKey:name]);
        NSAssert([ID isValid], @"ID error: %@ -> %@", name, [dict objectForKey:name]);
        [caches setObject:ID forKey:name];
    }
    
    // Constant IDs
    static NSString *moky = @"moky@4DnqXWdTV8wuZgfqSCX9GjE2kNq7HJrUgQ";
    static NSString *robot = @"assistant@2PpB6iscuBjA15oTjAsiswoX9qis5V3c1Dq";
    
    DIMID *founder = MKMIDFromString(moky);
    DIMID *assistant = MKMIDFromString(robot);
    
    DIMID *anyone = MKMAnyone();
    DIMID *everyone = MKMEveryone();
    
    // Reserved names
    [caches setObject:founder forKey:@"founder"];
    [caches setObject:anyone forKey:@"owner"];
    [caches setObject:assistant forKey:@"assistant"]; // group assistant (robot)
    
    [caches setObject:anyone forKey:@"anyone"];
    [caches setObject:everyone forKey:@"everyone"];
    [caches setObject:everyone forKey:@"all"];
    return caches;
}

- (BOOL)saveRecord:(DIMID *)ID forName:(NSString *)name {
    if ([name length] == 0) {
        return NO;
    }
    NSAssert([ID isValid], @"ID not valid: %@", ID);
    // cache
    [self.caches setObject:ID forKey:name];
    // save
    NSString *path = [self _ansFilePath];
    NSLog(@"saving ANS records from: %@", path);
    return [self dictionary:self.caches writeToBinaryFile:path];
}

- (DIMID *)recordForName:(NSString *)name {
    NSString *lowercase = [name lowercaseString];
    return [self.caches objectForKey:lowercase];
}

- (NSArray<NSString *> *)namesWithRecord:(NSString *)ID {
    NSDictionary<NSString *, DIMID *> *dict = self.caches;
    NSArray<NSString *> *allKeys = [dict allKeys];
    // all names
    if ([ID isEqualToString:@"*"]) {
        return allKeys;
    }
    // get keys with the same value
    NSMutableArray<NSString *> *keys = [[NSMutableArray alloc] init];
    DIMID *value;
    for (NSString *name in allKeys) {
        value = [dict objectForKey:name];
        if ([value isEqual:ID]) {
            [keys addObject:name];
        }
    }
    return keys;
}

@end
