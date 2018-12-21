//
//  DIMCAValidity.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMCAValidity.h"

@implementation DIMCAValidity

+ (instancetype)validityWithValidity:(id)validity {
    if ([validity isKindOfClass:[DIMCAValidity class]]) {
        return validity;
    } else if ([validity isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:validity];
    } else if ([validity isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:validity];
    } else {
        NSAssert(!validity, @"unexpected validity: %@", validity);
        return nil;
    }
}

- (instancetype)initWithNotBefore:(const NSDate *)from
                         notAfter:(const NSDate *)to {
    NSDictionary *dict = @{@"NotBefore":NSNumberFromDate(from),
                           @"NotAfter" :NSNumberFromDate(to),
                           };
    if (self = [super initWithDictionary:dict]) {
        _notBefore = [from copy];
        _notAfter = [to copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMCAValidity *validity = [super copyWithZone:zone];
    if (validity) {
        validity.notBefore = _notBefore;
        validity.notAfter = _notAfter;
    }
    return validity;
}

- (NSDate *)notBefore {
    if (!_notBefore) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"NotBefore"];
        NSAssert(timestamp, @"error: %@", _storeDictionary);
        _notBefore = NSDateFromNumber(timestamp);
    }
    return _notBefore;
}

- (NSDate *)notAfter {
    if (!_notAfter) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"NotAfter"];
        NSAssert(timestamp, @"error: %@", _storeDictionary);
        _notAfter = NSDateFromNumber(timestamp);
    }
    return _notAfter;
}

@end
