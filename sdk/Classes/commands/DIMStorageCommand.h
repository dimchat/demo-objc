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
//  DIMStorageCommand.h
//  DIMSDK
//
//  Created by Albert Moky on 2019/12/2.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Storage    @"storage"
#define DIMCommand_Contacts   @"contacts"
#define DIMCommand_PrivateKey @"private_key"

@interface DIMStorageCommand : DIMCommand

@property (readonly, strong, nonatomic) NSString *title;

//
//  ID string
//
@property (strong, nonatomic, nullable) NSString *ID;

//
//  Encrypted data
//      encrypted by a random password before upload
//
@property (strong, nonatomic, nullable) NSData *data;

//
//  Symmetric key
//      password to decrypt data
//      encrypted by user's public key before upload.
//      this should be empty when the storage data is "private_key".
//
@property (strong, nonatomic, nullable) NSData *key;

/*
*  Command message: {
*      type : 0x88,
*      sn   : 123,
*
*      command : "storage",
*      title   : "key name",  // "contacts", "private_key", ...
*
*      data    : "...",       // base64_encode(symmetric)
*      key     : "...",       // base64_encode(asymmetric)
*
*      // -- extra info
*      //...
*  }
*/
- (instancetype)initWithTitle:(NSString *)title;

#pragma mark Decryption

- (nullable NSData *)decryptWithSymmetricKey:(id<DIMDecryptKey>)PW;

- (nullable NSData *)decryptWithPrivateKey:(id<DIMDecryptKey>)SK;

@end

NS_ASSUME_NONNULL_END
