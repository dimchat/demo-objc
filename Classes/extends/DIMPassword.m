//
//  DIMPassword.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/10.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMPassword.h"

@implementation DIMPassword

+ (MKMSymmetricKey *)generateWithString:(NSString *)pwd {
    NSData *data = [pwd data];
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
                          @"data": [data base64Encode],
                          @"iv": [iv base64Encode],
                          };
    return MKMSymmetricKeyFromDictionary(key);
}

@end
