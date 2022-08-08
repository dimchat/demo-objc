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
//  DIMStorageCommand.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/12/2.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMStorageCommand.h"

@interface DIMStorageCommand () {
    
    NSString *_title;
    NSData *_data;
    NSData *_key;
    
    NSData *_plaintext;
    id<MKMDecryptKey> _password;
}

@end

@implementation DIMStorageCommand

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _title = nil;
        _data = nil;
        _key = nil;
        
        _plaintext = nil;
        _password = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _title = nil;
        _data = nil;
        _key = nil;
        
        _plaintext = nil;
        _password = nil;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [self initWithCommandName:DIMCommand_Storage]) {
        NSAssert([title length] > 0, @"storage title should not be empty");
        NSAssert(![title isEqualToString:DIMCommand_Storage], @"title error: %@", title);
        [self setObject:title forKey:@"title"];
        _title = title;
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        _title = [self objectForKey:@"title"];
        if (!_title) {
            // (compatible with v1.0)
            //  contacts command: {
            //      cmd     : "contacts",
            //      data    : "...",
            //      key     : "...",
            //  }
            _title = self.cmd;
            NSAssert(![_title isEqualToString:DIMCommand_Storage], @"title error: %@", _title);
        }
    }
    return _title;
}

- (nullable id<MKMID>)ID {
    return MKMIDFromString([self objectForKey:@"ID"]);
}

- (void)setID:(id<MKMID>)ID {
    [self setObject:[ID string] forKey:@"ID"];
}

- (nullable NSData *)data {
    if (!_data) {
        NSString *base64 = [self objectForKey:@"data"];
        if (base64) {
            _data = MKMBase64Decode(base64);
        }
    }
    return _data;
}

- (void)setData:(NSData *)data {
    if (data) {
        [self setObject:MKMBase64Encode(data) forKey:@"data"];
    } else {
        [self removeObjectForKey:@"data"];
    }
    _data = data;
    _plaintext = nil;
}

- (nullable NSData *)key {
    if (!_key) {
        NSString *base64 = [self objectForKey:@"key"];
        if (base64) {
            _key = MKMBase64Decode(base64);
        }
    }
    return _key;
}

- (void)setKey:(NSData *)keyData {
    if (keyData) {
        [self setObject:MKMBase64Encode(keyData) forKey:@"key"];
    } else {
        [self removeObjectForKey:@"key"];
    }
    _key = keyData;
    _password = nil;
}

#pragma mark Decryption

- (nullable NSData *)decryptWithSymmetricKey:(id<MKMDecryptKey>)PW {
    NSAssert([PW conformsToProtocol:@protocol(MKMSymmetricKey)], @"password error: %@", PW);
    if (!_plaintext) {
        NSAssert(PW, @"password should not be empty");
        NSData *data = self.data;
        NSAssert([data length] > 0, @"data empty: %@", self);
        _plaintext = [PW decrypt:data];
    }
    return _plaintext;
}

- (nullable NSData *)decryptWithPrivateKey:(id<MKMDecryptKey>)SK {
    if (!_password) {
        NSData *key = self.key;
        NSAssert([key length] > 0, @"key empty: %@", self);
        key = [SK decrypt:key];
        NSAssert([key length] > 0, @"failed to decrypt key data: %@ with private key: %@", self, SK);
        id dict = MKMJSONDecode(MKMUTF8Decode(key));
        _password = MKMSymmetricKeyFromDictionary(dict);
    }
    return [self decryptWithSymmetricKey:_password];
}

@end
