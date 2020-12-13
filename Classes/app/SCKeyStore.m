// license: https://mit-license.org
//
//  SeChat : Secure/secret Chat Application
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  SCKeyStore.m
//  DIMClient
//
//  Created by Albert Moky on 2020/12/13.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "SCKeyStore.h"

static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

// receiver -> key
typedef NSMutableDictionary<id<MKMID>, id<MKMSymmetricKey>> KeyTable;
// sender -> map<receiver, key>
typedef NSMutableDictionary<id<MKMID>, KeyTable *> KeyMap;

@interface SCKeyStore () {
    
    KeyMap *_keyMap;
    
    BOOL _dirty;
}

@end

@implementation SCKeyStore

SingletonImplementations(SCKeyStore, sharedInstance)

- (void)dealloc {
    [self flush];
    //[super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
        _keyMap = [[KeyMap alloc] init];
        
        // load keys from local storage
        [self reload];
        
        _dirty = NO;
    }
    return self;
}

- (void)flush {
    if (!_dirty) {
        // nothing changed
        return ;
    }
    if ([self saveKeys:_keyMap]) {
        // keys saved
        _dirty = NO;
    }
}

- (BOOL)saveKeys:(NSDictionary *)keyMap {
    // "Library/Caches/keystore.plist"
    NSString *dir = caches_directory();
    NSString *path = [dir stringByAppendingPathComponent:@"keystore.plist"];
    return [keyMap writeToBinaryFile:path];
}

- (nullable NSDictionary *)loadKeys {
    NSString *dir = caches_directory();
    NSString *path = [dir stringByAppendingPathComponent:@"keystore.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return nil;
}

- (BOOL)reload {
    NSDictionary *keys = [self loadKeys];
    if (!keys) {
        return NO;
    }
    return [self updateKeys:keys];
}

- (BOOL)updateKeys:(NSDictionary *)keyMap {
    BOOL changed = NO;
    id<MKMSymmetricKey> oldKey, newKey;
    for (NSString *from in keyMap) {
        id<MKMID> sender = MKMIDFromString(from);
        NSDictionary *keyTable = [keyMap objectForKey:from];
        for (NSString *to in keyTable) {
            id<MKMID> receiver = MKMIDFromString(to);
            NSDictionary *keyDict = [keyTable objectForKey:to];
            newKey = MKMSymmetricKeyFromDictionary(keyDict);
            NSAssert(newKey, @"key error(%@ -> %@): %@", from, to, keyDict);
            // check whether exists an old key
            oldKey = [self _cipherKeyFrom:sender to:receiver];
            if (![oldKey isEqual:newKey]) {
                changed = YES;
            }
            // cache key with direction
            [self _cacheCipherKey:newKey from:sender to:receiver];
        }
    }
    return changed;
}

- (nullable id<MKMSymmetricKey>)_cipherKeyFrom:(id<MKMID>)sender
                                            to:(id<MKMID>)receiver {
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    return [keyTable objectForKey:receiver];
}

- (void)_cacheCipherKey:(id<MKMSymmetricKey>)key
                   from:(id<MKMID>)sender
                     to:(id<MKMID>)receiver {
    NSAssert([key isKindOfClass:[NSDictionary class]], @"cipher key cannot be empty");
    NSDictionary *keyInfo = (NSDictionary *)key;
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    if (keyTable) {
        id<MKMSymmetricKey> old = [keyTable objectForKey:receiver];
        if (old) {
            // check whether same key exists
            BOOL equals = YES;
            id v1, v2;
            for (NSString *k in keyInfo) {
                v1 = [key objectForKey:k];
                v2 = [old objectForKey:k];
                if (!v1) {
                    if (!v2) {
                        continue;
                    }
                } else if ([v1 isEqual:v2]) {
                    continue;
                }
                equals = NO;
                break;
            }
            if (equals) {
                // no need to update
                return;
            }
        }
    } else {
        keyTable = [[KeyTable alloc] init];
        [_keyMap setObject:keyTable forKey:sender];
    }
    [keyTable setObject:key forKey:receiver];
}

#pragma mark - DIMCipherKeyDelegate

// TODO: override to check whether key expired for sending message
- (nullable id<MKMSymmetricKey>)cipherKeyFrom:(id<MKMID>)sender
                                           to:(id<MKMID>)receiver
                                     generate:(BOOL)create {
    if (MKMIDIsBroadcast(receiver)) {
        return MKMSymmetricKeyWithAlgorithm(@"PLAIN");
    }
    // get key from cache
    id<MKMSymmetricKey> key = [self _cipherKeyFrom:sender to:receiver];
    if (!key && create) {
        key = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        if (key) {
            [self _cacheCipherKey:key from:sender to:receiver];
        }
    }
    return key;
}

- (void)cacheCipherKey:(id<MKMSymmetricKey>)key
                  from:(id<MKMID>)sender
                    to:(id<MKMID>)receiver {
    if (MKMIDIsBroadcast(receiver)) {
        // broadcast message has no key
        return;
    }
    [self _cacheCipherKey:key from:sender to:receiver];
    _dirty = YES;
}

@end
