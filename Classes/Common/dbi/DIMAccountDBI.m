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
//  DIMAccountDBI.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMAccountDBI.h"

NSArray<id<MKMDecryptKey>> *DIMConvertDecryptKeys(NSArray<id<MKMPrivateKey>> *privateKeys) {
    NSMutableArray<id<MKMDecryptKey>> *decryptKeys = [[NSMutableArray alloc] initWithCapacity:[privateKeys count]];
    for (id<MKMPrivateKey> key in privateKeys) {
        if ([key conformsToProtocol:@protocol(MKMDecryptKey)]) {
            [decryptKeys addObject:(id<MKMDecryptKey>)key];
        }
    }
    return decryptKeys;
}

NSArray<id<MKMPrivateKey>> *DIMConvertPrivateKeys(NSArray<id<MKMDecryptKey>> *decryptKeys) {
    NSMutableArray<id<MKMPrivateKey>> *privateKeys = [[NSMutableArray alloc] initWithCapacity:[decryptKeys count]];
    for (id<MKMDecryptKey> key in decryptKeys) {
        if ([key conformsToProtocol:@protocol(MKMPrivateKey)]) {
            [privateKeys addObject:(id<MKMPrivateKey>)key];
        }
    }
    return privateKeys;
}

NSArray<NSDictionary<NSString *, id> *> *DIMRevertPrivateKeys(NSArray<id<MKMPrivateKey>> *privateKeys) {
    NSMutableArray<id> *array = [[NSMutableArray alloc] initWithCapacity:[privateKeys count]];
    for (id<MKMPrivateKey> key in privateKeys) {
        [array addObject:key.dictionary];
    }
    return array;
}

NSArray<id<MKMPrivateKey>> *DIMUnshiftPrivateKey(id<MKMPrivateKey> key, NSMutableArray<id<MKMPrivateKey>> *privateKeys) {
    NSInteger index = DIMFindPrivateKey(key, privateKeys);
    if (index == 0) {
        // nothing change
        return nil;
    } else if (index > 0) {
        // move to the front
        [privateKeys removeObjectAtIndex:index];
    } else if ([privateKeys count] > 2) {
        // keep only last three records
        [privateKeys removeLastObject];
    }
    [privateKeys insertObject:key atIndex:0];
    return privateKeys;
}

NSInteger DIMFindPrivateKey(id<MKMPrivateKey> key, NSArray<id<MKMPrivateKey>> *privateKeys) {
    NSString *data = [key stringForKey:@"data"];
    assert(data.length > 0);
    NSInteger index = 0;
    for (id<MKMPrivateKey> item in privateKeys) {
        if ([[item stringForKey:@"data"] isEqualToString:data]) {
            return index;
        } else {
            index += 1;
        }
    }
    return -1;
}
