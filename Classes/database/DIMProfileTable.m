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
//  DIMProfileTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMFacebook+Extension.h"

#import "NSDate+Timestamp.h"
#import "DIMClientConstants.h"
#import "DIMProfileTable.h"

typedef NSMutableDictionary<DIMID *, DIMProfile *> CacheTableM;

@interface DIMProfileTable () {
    
    CacheTableM *_caches;
}

@end

@implementation DIMProfileTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
    }
    return self;
}

/**
 *  Get profile filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/profile.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"profile.plist"];
}

- (BOOL)_cacheProfile:(DIMProfile *)profile {
    if (![profile isValid]) {
        //NSAssert(false, @"profile not valid: %@", profile);
        return NO;
    }
    [_caches setObject:profile forKey:profile.ID];
    return YES;
}

- (nullable __kindof DIMProfile *)_loadProfileForID:(DIMID *)ID {
    NSString *path = [self _filePathWithID:ID];
    NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
    if (!dict) {
        NSLog(@"profile not found: %@", path);
        return nil;
    }
    NSLog(@"profile from: %@", path);
    return MKMProfileFromDictionary(dict);
}

- (nullable DIMProfile *)profileForID:(DIMID *)ID {
    DIMProfile *profile = [_caches objectForKey:ID];
    if (!profile) {
        // first access, try to load from local storage
        profile = [self _loadProfileForID:ID];
        if (profile) {
            // verify and cache it
            [self _cacheProfile:profile];
        } else {
            // place an empty profile for cache
            profile = [[DIMProfile alloc] initWithID:ID];
            [_caches setObject:profile forKey:ID];
        }
    }
    return profile;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    
    NSDate *now = [[NSDate alloc] init];
    [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
    
    if (![self _cacheProfile:profile]) {
        return NO;
    }
    DIMID *ID = DIMIDWithString(profile.ID);
    NSString *path = [self _filePathWithID:ID];
    NSLog(@"saving profile into: %@", path);
    BOOL result = [self dictionary:profile writeToBinaryFile:path];
    
    if(result){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ProfileUpdated object:nil userInfo:@{@"ID":profile.ID}];
    }
    
    return result;
}

@end
