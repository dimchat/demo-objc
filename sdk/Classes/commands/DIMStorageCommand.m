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

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "DIMStorageCommand.h"

@interface DIMStorageCommand () {
    
    NSString *_title;
    NSData *_data;
    NSData *_key;
    
    NSData *_plaintext;
    id<DIMDecryptKey> _password;
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
    if (self = [self initWithCommand:DIMCommand_Storage]) {
        NSAssert([title length] > 0, @"storage title should not be empty");
        NSAssert(![title isEqualToString:DIMCommand_Storage], @"title error: %@", title);
        [_storeDictionary setObject:title forKey:@"title"];
        _title = title;
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        _title = [_storeDictionary objectForKey:@"title"];
        if (!_title) {
            // (compatible with v1.0)
            //  contacts command: {
            //      command : "contacts",
            //      data    : "...",
            //      key     : "...",
            //  }
            _title = self.command;
            NSAssert(![_title isEqualToString:DIMCommand_Storage], @"title error: %@", _title);
        }
    }
    return _title;
}

- (nullable NSString *)ID {
    return [_storeDictionary objectForKey:@"ID"];
}

- (void)setID:(NSString *)ID {
    [_storeDictionary setObject:ID forKey:@"ID"];
}

- (nullable NSData *)data {
    if (!_data) {
        NSString *base64 = [_storeDictionary objectForKey:@"data"];
        if (base64) {
            _data = [base64 base64Decode];
        }
    }
    return _data;
}

- (void)setData:(NSData *)data {
    if (data) {
        [_storeDictionary setObject:[data base64Encode] forKey:@"data"];
    } else {
        [_storeDictionary removeObjectForKey:@"data"];
    }
    _data = data;
    _plaintext = nil;
}

- (nullable NSData *)key {
    if (!_key) {
        NSString *base64 = [_storeDictionary objectForKey:@"key"];
        if (base64) {
            _key = [base64 base64Decode];
        }
    }
    return _key;
}

- (void)setKey:(NSData *)keyData {
    if (keyData) {
        [_storeDictionary setObject:[keyData base64Encode] forKey:@"key"];
    } else {
        [_storeDictionary removeObjectForKey:@"key"];
    }
    _key = keyData;
}

#pragma mark Decryption

- (nullable NSData *)decryptWithSymmetricKey:(id<DIMDecryptKey>)PW {
    NSAssert([PW conformsToProtocol:@protocol(MKMSymmetricKey)], @"password error: %@", PW);
    if (_plaintext) {
        // already decrypted
        return _plaintext;
    }
    NSData *data = self.data;
    NSAssert([data length] > 0, @"data empty: %@", self);
    _plaintext = [PW decrypt:data];
    return _plaintext;
}

- (nullable NSData *)decryptWithPrivateKey:(id<DIMDecryptKey>)SK {
    if (_plaintext) {
        // already decrypted
        return _plaintext;
    }
    if (!_password) {
        NSData *keyData = self.key;
        NSAssert([keyData length] > 0, @"key empty: %@", self);
        keyData = [SK decrypt:keyData];
        if ([keyData length] == 0) {
            //NSAssert(false, @"failed to decrypt key data: %@ wity private key: %@", self, SK);
            return nil;
        }
        NSDictionary *dict = [keyData jsonDictionary];
        _password = MKMSymmetricKeyFromDictionary(dict);
    }
    return [self decryptWithSymmetricKey:_password];
}

@end
