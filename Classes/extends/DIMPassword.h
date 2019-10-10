//
//  DIMPassword.h
//  DIMClient
//
//  Created by Albert Moky on 2019/10/10.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMPassword : MKMSymmetricKey

+ (MKMSymmetricKey *)generateWithString:(NSString *)pwd;

@end

// generate AES key with password string
#define DIMPasswordFromString(pwd)                                             \
            [DIMPassword generateWithString:(pwd)]                             \
                                           /* EOF 'DIMPasswordFromString(pwd) */

NS_ASSUME_NONNULL_END
