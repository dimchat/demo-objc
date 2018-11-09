//
//  DIMCertificateAuthority.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMCertificateAuthority.h"

@implementation DIMCASubject

+ (instancetype)subjectWithSubject:(id)subject {
    if ([subject isKindOfClass:[DIMCASubject class]]) {
        return subject;
    } else if ([subject isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:subject];
    } else if ([subject isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:subject];
    } else {
        NSAssert(!subject, @"unexpected subject: %@", subject);
        return nil;
    }
}

#pragma mark 'C' for Country

- (NSString *)country {
    return [_storeDictionary objectForKey:@"C"];
}

- (void)setCountry:(NSString *)country {
    if (country) {
        [_storeDictionary setObject:country forKey:@"C"];
    } else {
        [_storeDictionary removeObjectForKey:@"C"];
    }
}

#pragma mark 'ST' for State/Province

- (NSString *)state {
    return [_storeDictionary objectForKey:@"ST"];
}

- (void)setState:(NSString *)state {
    if (state) {
        [_storeDictionary setObject:state forKey:@"ST"];
    } else {
        [_storeDictionary removeObjectForKey:@"ST"];
    }
}

#pragma mark 'L' for Locality

- (NSString *)locality {
    return [_storeDictionary objectForKey:@"L"];
}

- (void)setLocality:(NSString *)locality {
    if (locality) {
        [_storeDictionary setObject:locality forKey:@"L"];
    } else {
        [_storeDictionary removeObjectForKey:@"L"];
    }
}

#pragma mark 'O' for Organization

- (NSString *)organization {
    return [_storeDictionary objectForKey:@"O"];
}

- (void)setOrganization:(NSString *)organization {
    if (organization) {
        [_storeDictionary setObject:organization forKey:@"O"];
    } else {
        [_storeDictionary removeObjectForKey:@"O"];
    }
}

#pragma mark 'OU' for Organization Unit

- (NSString *)organizationUnit {
    return [_storeDictionary objectForKey:@"OU"];
}

- (void)setOrganizationUnit:(NSString *)organizationUnit {
    if (organizationUnit) {
        [_storeDictionary setObject:organizationUnit forKey:@"OU"];
    } else {
        [_storeDictionary removeObjectForKey:@"OU"];
    }
}

#pragma mark 'CN' for Common Name

- (NSString *)commonName {
    return [_storeDictionary objectForKey:@"CN"];
}

- (void)setCommonName:(NSString *)commonName {
    if (commonName) {
        [_storeDictionary setObject:commonName forKey:@"CN"];
    } else {
        [_storeDictionary removeObjectForKey:@"CN"];
    }
}

@end

#pragma mark -

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
    NSDictionary *dict = @{@"NotBefore":@([from timeIntervalSince1970]),
                           @"NotAfter" :@([to timeIntervalSince1970]),
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
        NSNumber *num = [_storeDictionary objectForKey:@"NotBefore"];
        NSTimeInterval ti = [num doubleValue];
        _notBefore = [[NSDate alloc] initWithTimeIntervalSince1970:ti];
    }
    return _notBefore;
}

- (NSDate *)notAfter {
    if (!_notAfter) {
        NSNumber *num = [_storeDictionary objectForKey:@"NotAfter"];
        NSTimeInterval ti = [num doubleValue];
        _notAfter = [[NSDate alloc] initWithTimeIntervalSince1970:ti];
    }
    return _notAfter;
}

@end

#pragma mark -

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

- (MKMPublicKey *)publicKey {
    MKMPublicKey *PK = [_storeDictionary objectForKey:@"PublicKey"];
    return [MKMPublicKey keyWithKey:PK];
}

- (void)setPublicKey:(MKMPublicKey *)publicKey {
    if (publicKey) {
        [_storeDictionary setObject:publicKey forKey:@"PublicKey"];
    } else {
        [_storeDictionary removeObjectForKey:@"PublicKey"];
    }
}

@end

#pragma mark -

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
    NSMutableDictionary *ext = [_storeDictionary objectForKey:@"Extensions"];
    if (!ext) {
        ext = [[NSMutableDictionary alloc] init];
        [_storeDictionary setObject:ext forKey:@"Extensions"];
    }
    [ext setObject:value forKey:key];
}

#pragma mark - Verify

- (BOOL)verifyWithPublicKey:(const MKMPublicKey *)PK {
    NSString *json = [_storeDictionary objectForKey:@"Info"];
    NSData *hash = [[json data] sha256d];
    return [PK verify:hash withSignature:self.signature];
}

@end
