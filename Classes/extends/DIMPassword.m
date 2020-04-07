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
//  DIMPassword.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/10.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Crypto.h"

#import "DIMPassword.h"

@implementation DIMPassword

+ (MKMSymmetricKey *)generateWithString:(NSString *)pwd {
    NSData *data = MKMUTF8Encode(pwd);
    NSData *digest = [data sha256];
    // AES key data
    NSInteger len = 32 - [data length];
    if (len > 0) {
        // format: {digest_prefix}+{pwd_data}
        NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:32];
        [mData appendData:[digest subdataWithRange:NSMakeRange(0, len)]];
        [mData appendData:data];
        data = mData;
    } else if (len < 0) {
        NSAssert(false, @"password too long: %@", pwd);
        data = digest;
    }
    // AES iv
    NSRange range = NSMakeRange(32 - kCCBlockSizeAES128, kCCBlockSizeAES128);
    NSData *iv = [digest subdataWithRange:range];
    NSDictionary *key = @{
                          @"algorithm": SCAlgorithmAES,
                          @"data": MKMBase64Encode(data),
                          @"iv": MKMBase64Encode(iv),
                          };
    return MKMSymmetricKeyFromDictionary(key);
}

@end
