//
//  DIMCAData.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCASubject.h"
#import "DIMCAValidity.h"

#import "DIMCAData.h"

@implementation DIMCAData

+ (instancetype)dataWithData:(id)data {
    if ([data isKindOfClass:[DIMCAData class]]) {
        return data;
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:data];
    } else if ([data isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:data];
    } else {
        NSAssert(!data, @"unexpected data: %@", data);
        return nil;
    }
}

#pragma mark Issuer

- (DIMCASubject *)issuer {
    DIMCASubject *sub = [_storeDictionary objectForKey:@"Issuer"];
    return [DIMCASubject subjectWithSubject:sub];
}

- (void)setIssuer:(DIMCASubject *)issuer {
    if (issuer) {
        [_storeDictionary setObject:issuer forKey:@"Issuer"];
    } else {
        [_storeDictionary removeObjectForKey:@"Issuer"];
    }
}

#pragma mark Validity

- (DIMCAValidity *)validity {
    DIMCAValidity *val = [_storeDictionary objectForKey:@"Validity"];
    return [DIMCAValidity validityWithValidity:val];
}

- (void)setValidity:(DIMCAValidity *)validity {
    if (validity) {
        [_storeDictionary setObject:validity forKey:@"Validity"];
    } else {
        [_storeDictionary removeObjectForKey:@"Validity"];
    }
}

#pragma mark Subject

- (DIMCASubject *)subject {
    DIMCASubject *sub = [_storeDictionary objectForKey:@"Subject"];
    return [DIMCASubject subjectWithSubject:sub];
}

- (void)setSubject:(DIMCASubject *)subject {
    if (subject) {
        [_storeDictionary setObject:subject forKey:@"Subject"];
    } else {
        [_storeDictionary removeObjectForKey:@"Subject"];
    }
}

#pragma mark PublicKey

- (DIMPublicKey *)publicKey {
    DIMPublicKey *PK = [_storeDictionary objectForKey:@"PublicKey"];
    return [DIMPublicKey keyWithKey:PK];
}

- (void)setPublicKey:(DIMPublicKey *)publicKey {
    if (publicKey) {
        [_storeDictionary setObject:publicKey forKey:@"PublicKey"];
    } else {
        [_storeDictionary removeObjectForKey:@"PublicKey"];
    }
}

@end
