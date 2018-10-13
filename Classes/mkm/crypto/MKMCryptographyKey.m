//
//  MKMCryptographyKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMCryptographyKey.h"

@interface MKMCryptographyKey ()

@property (strong, nonatomic) const NSString *algorithm;

@end

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
        return nil;
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

- (instancetype)initWithAlgorithm:(const NSString *)algorithm {
    NSDictionary *dict = @{@"algorithm":algorithm};
    self = [self initWithAlgorithm:algorithm keyInfo:dict];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    NSString *algor = [dict objectForKey:@"algorithm"];
    if (algorithm) {
        NSAssert([algorithm isEqualToString:algor],
                 @"key data error: %@", info);
    } else {
        algorithm = algor;
    }
    
    if (self = [self initWithDictionary:dict]) {
        self.algorithm = algorithm;
    }
    return self;
}

- (BOOL)isEqual:(const MKMCryptographyKey *)aKey {
    return [aKey isEqualToDictionary:_storeDictionary];
}

@end

@implementation MKMCryptographyKey (PersistentStore)

- (BOOL)saveKeyWithCode:(NSUInteger)code {
    NSAssert(false, @"DON'T call me");
    // let the subclass to do the job
    return NO;
}

+ (instancetype)loadKeyWithCode:(NSUInteger)code {
    NSAssert(false, @"DON'T call me");
    // let the subclass to do the job
    return nil;
}

@end
