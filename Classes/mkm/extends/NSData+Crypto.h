//
//  NSData+Crypto.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Encode)

- (NSString *)hexEncode;

- (NSString *)base58Encode;
- (NSString *)base64Encode;

@end

@interface NSData (Hash)

- (NSData *)md5;

- (NSData *)sha1;
- (NSData *)sha224;
- (NSData *)sha256;
- (NSData *)sha384;
- (NSData *)sha512;

- (NSData *)sha256d; // sha256(sha256(data))

- (NSData *)ripemd160;

@end

@interface NSData (AES)

- (NSData *)AES256EncryptWithKey:(const NSData *)key;

- (NSData *)AES256DecryptWithKey:(const NSData *)key;

@end

NS_ASSUME_NONNULL_END
