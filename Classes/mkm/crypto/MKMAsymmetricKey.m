//
//  MKMAsymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMAsymmetricKey.h"

@interface MKMAsymmetricKey ()

@property (strong, nonatomic) const NSString *algorithm;
@property (strong, nonatomic) const NSDictionary *acKeyInfo;

@end

@implementation MKMAsymmetricKey

- (instancetype)initWithJSONString:(const NSString *)json {
    NSData *data = [json data];
    NSDictionary *dict = [data jsonDictionary];
    NSString *algor = [dict objectForKey:@"algorithm"];
    NSAssert(algor, @"key data error");
    
    self = [self initWithAlgorithm:algor keyInfo:dict];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSString *algor = [info objectForKey:@"algorithm"];
    if (algorithm) {
        NSAssert([algorithm isEqualToString:algor], @"key data error");
    } else {
        algorithm = algor;
    }
    
    if (self = [self initWithDictionary:[info copy]]) {
        self.algorithm = algorithm;
        self.acKeyInfo = info;
    }
    return self;
}

@end
