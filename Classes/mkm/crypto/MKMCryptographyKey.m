//
//  MKMCryptographyKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMCryptographyKey.h"

@implementation MKMCryptographyKey

+ (instancetype)keyWithKey:(id)key {
    if ([key isKindOfClass:[MKMCryptographyKey class]]) {
        return key;
    } else if ([key isKindOfClass:[NSDictionary class]]) {
        NSString *algor = [key objectForKey:@"algorithm"];
        NSAssert(algor, @"key data error");
        return [[self alloc] initWithAlgorithm:algor keyInfo:key];
    } else if ([key isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:key];
    } else {
        NSAssert(!key, @"unexpected key: %@", key);
        return key;
    }
}

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
    NSDictionary *dict = [info copy];
    NSString *algor = [dict objectForKey:@"algorithm"];
    if (algorithm) {
        NSAssert([algorithm isEqualToString:algor], @"key data error");
    } else {
        algorithm = algor;
    }
    
    if (self = [self initWithDictionary:dict]) {
        _algorithm = [algorithm copy];
    }
    return self;
}

@end
