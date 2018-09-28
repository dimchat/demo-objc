//
//  NSObject+JsON.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

@implementation NSObject (JsON)

- (NSData *)jsonData {
    NSData *data = nil;
    
    BOOL valid = [NSJSONSerialization isValidJSONObject:self];
    NSAssert(valid, @"object format not support for json: %@", self);
    if (valid) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:self
                                               options:NSJSONWritingSortedKeys
                                                 error:&error];
        NSAssert(!error, @"json error");
    }
    
    return data;
}

- (NSString *)jsonString {
    return [[self jsonData] UTF8String];
}

@end

@implementation NSString (Convert)

- (NSData *)data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (Convert)

- (NSString *)UTF8String {
    return [[NSString alloc] initWithData:self
                                 encoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (JsON)

- (id)jsonObject {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    NSAssert(!error, @"json error: %@", self);
    return obj;
}

- (id)jsonMutableContainer {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, @"json error: %@", self);
    return obj;
}

- (NSString *)jsonString {
    return [self jsonObject];
}

- (NSArray *)jsonArray {
    return [self jsonObject];
}

- (NSDictionary *)jsonDictionary {
    return [self jsonObject];
}

- (NSMutableArray *)jsonMutableArray {
    return [self jsonMutableContainer];
}

- (NSMutableDictionary *)jsonMutableDictionary {
    return [self jsonMutableContainer];
}

@end
