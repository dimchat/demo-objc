//
//  MKMCryptographyKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMAESKey.h"
#import "MKMRSAPrivateKey.h"
#import "MKMRSAPublicKey.h"
#import "MKMECCPrivateKey.h"
#import "MKMECCPublicKey.h"

#import "MKMCryptographyKey.h"

@interface MKMCryptographyKey ()

@property (strong, nonatomic) NSString *algorithm;

@end

@implementation MKMCryptographyKey

+ (instancetype)keyWithKey:(id)key {
    if ([key isKindOfClass:[MKMCryptographyKey class]]) {
        return key;
    } else if ([key isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:key];
    } else if ([key isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:key];
    } else {
        NSAssert(!key, @"unexpected key: %@", key);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    self = [self initWithDictionary:dict];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy
        _algorithm = nil;
    }
    return self;
}

- (instancetype)initWithJSONString:(const NSString *)json {
    NSDictionary *dict = [[json data] jsonDictionary];
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm {
    NSDictionary *keyInfo = @{@"algorithm":algorithm};
    self = [self initWithDictionary:keyInfo];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMCryptographyKey *key = [super copyWithZone:zone];
    if (key) {
        key.algorithm = _algorithm;
    }
    return key;
}

- (BOOL)isEqual:(const MKMCryptographyKey *)aKey {
    return [aKey isEqualToDictionary:_storeDictionary];
}

- (NSString *)algorithm {
    if (!_algorithm) {
        _algorithm = [_storeDictionary objectForKey:@"algorithm"];
        NSAssert(_algorithm, @"key info error: %@", _storeDictionary);
    }
    return _algorithm;
}

@end

@implementation MKMCryptographyKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    NSAssert(false, @"override me in subclass");
    // let the subclass to do the job
    return nil;
}

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier {
    NSAssert(false, @"override me in subclass");
    // let the subclass to do the job
    return NO;
}

@end
