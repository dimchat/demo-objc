//
//  DIMUser.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMUser.h"

@implementation DIMUser

- (NSData *)decrypt:(const NSData *)ciphertext {
    const MKMPrivateKey *SK = [_keyStore privateKey];
    return [SK decrypt:ciphertext];
}

- (NSData *)sign:(const NSData *)plaintext {
    const MKMPrivateKey *SK = [_keyStore privateKey];
    return [SK sign:plaintext];
}

@end
