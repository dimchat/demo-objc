//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

@implementation MKMSymmetricKey

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    NSAssert([algorithm isEqualToString:[dict objectForKey:@"algorithm"]], @"algorithm error: %@, %@", algorithm, info);
    
    if ([self isMemberOfClass:[MKMSymmetricKey class]]) {
        // create instance with algorithm
        if ([algorithm isEqualToString:SCAlgorithmAES]) {
            self = [[MKMAESKey alloc] initWithAlgorithm:algorithm keyInfo:dict];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else {
        NSAssert([[self class] isSubclassOfClass:[MKMSymmetricKey class]], @"error");
        // subclass
        self = [super initWithAlgorithm:algorithm keyInfo:info];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        NSString *PW = [dict objectForKey:@"passphrase"];
        if (!PW) {
            PW = [dict objectForKey:@"password"];
        }
        NSAssert(PW, @"key data error: %@", dict);
        _passphrase = [PW copy];
    }
    return self;
}

@end
