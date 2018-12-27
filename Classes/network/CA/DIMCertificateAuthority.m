//
//  DIMCertificateAuthority.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMCAData.h"

#import "DIMCertificateAuthority.h"

@implementation DIMCertificateAuthority

+ (instancetype)caWithCA:(id)ca {
    if ([ca isKindOfClass:[DIMCertificateAuthority class]]) {
        return ca;
    } else if ([ca isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:ca];
    } else if ([ca isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:ca];
    } else {
        NSAssert(!ca, @"unexpected CA: %@", ca);
        return nil;
    }
}

#pragma mark Version

- (NSUInteger)version {
    NSNumber *num = [_storeDictionary objectForKey:@"Version"];
    return [num unsignedIntegerValue];
}

- (void)setVersion:(NSUInteger)version {
    [_storeDictionary setObject:@(version) forKey:@"Version"];
}

#pragma mark SerialNumber

- (NSString *)serialNumber {
    return [_storeDictionary objectForKey:@"SerialNumber"];
}

- (void)setSerialNumber:(NSString *)serialNumber {
    if (serialNumber) {
        [_storeDictionary setObject:serialNumber forKey:@"SerialNumber"];
    } else {
        [_storeDictionary removeObjectForKey:@"SerialNumber"];
    }
}

#pragma mark Info (CAData)

- (DIMCAData *)info {
    NSString *json = [_storeDictionary objectForKey:@"Info"];
    return [DIMCAData dataWithData:json];
}

- (void)setInfo:(DIMCAData *)info {
    if (info) {
        NSString *json = [info jsonString];
        [_storeDictionary setObject:json forKey:@"Info"];
    } else {
        [_storeDictionary removeObjectForKey:@"Info"];
    }
}

#pragma mark Signature

- (NSData *)signature {
    NSString *encode = [_storeDictionary objectForKey:@"Signature"];
    return [encode base64Decode];
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        NSString *encode = [signature base64Encode];
        [_storeDictionary setObject:encode forKey:@"Signature"];
    } else {
        [_storeDictionary removeObjectForKey:@"Signature"];
    }
}

#pragma mark Extensions

- (NSMutableDictionary *)extensions {
    return [_storeDictionary objectForKey:@"Extensions"];
}

- (void)setExtraValue:(id)value forKey:(const NSString *)key {
    NSAssert(value, @"extra value cannot be empty");
    NSMutableDictionary *ext = [_storeDictionary objectForKey:@"Extensions"];
    if (!ext) {
        ext = [[NSMutableDictionary alloc] init];
        [_storeDictionary setObject:ext forKey:@"Extensions"];
    }
    if (value) {
        [ext setObject:value forKey:key];
    }
}

#pragma mark - Verify

- (BOOL)verifyWithPublicKey:(const DIMPublicKey *)PK {
    NSString *json = [_storeDictionary objectForKey:@"Info"];
    return [PK verify:[json data] withSignature:self.signature];
}

@end
