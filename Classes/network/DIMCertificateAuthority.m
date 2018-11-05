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
    } else {
        NSAssert(!subject, @"unexpected subject: %@", subject);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        _country  = [dict objectForKey:@"C"];
        _state    = [dict objectForKey:@"ST"];
        _locality = [dict objectForKey:@"L"];
        
        _organization     = [dict objectForKey:@"O"];
        _organizationUnit = [dict objectForKey:@"OU"];
        _commonName       = [dict objectForKey:@"CN"];
    }
    return self;
}

- (void)setCountry:(NSString *)country {
    if (country) {
        if (![_country isEqualToString:country]) {
            [_storeDictionary setObject:country forKey:@"C"];
            _country = country;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"C"];
        _country = nil;
    }
}

- (void)setState:(NSString *)state {
    if (state) {
        if (![_state isEqualToString:state]) {
            [_storeDictionary setObject:state forKey:@"ST"];
            _state = state;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"ST"];
        _state = nil;
    }
}

- (void)setLocality:(NSString *)locality {
    if (locality) {
        if (![_locality isEqualToString:locality]) {
            [_storeDictionary setObject:locality forKey:@"L"];
            _locality = locality;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"L"];
        _locality = nil;
    }
}

- (void)setOrganization:(NSString *)organization {
    if (organization) {
        if (![_organization isEqualToString:organization]) {
            [_storeDictionary setObject:organization forKey:@"O"];
            _organization = organization;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"O"];
        _organization = nil;
    }
}

- (void)setOrganizationUnit:(NSString *)organizationUnit {
    if (organizationUnit) {
        if (![_organizationUnit isEqualToString:organizationUnit]) {
            [_storeDictionary setObject:organizationUnit forKey:@"OU"];
            _organizationUnit = organizationUnit;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"OU"];
        _organizationUnit = nil;
    }
}

- (void)setCommonName:(NSString *)commonName {
    if (commonName) {
        if (![_commonName isEqualToString:commonName]) {
            [_storeDictionary setObject:commonName forKey:@"CN"];
            _commonName = commonName;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"CN"];
        _commonName = nil;
    }
}

@end

#pragma mark -

@interface DIMCAValidity ()

@property (strong, nonatomic) NSDate *notBefore;
@property (strong, nonatomic) NSDate *notAfter;

@end

@implementation DIMCAValidity

+ (instancetype)validityWithValidity:(id)validity {
    if ([validity isKindOfClass:[DIMCAValidity class]]) {
        return validity;
    } else if ([validity isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:validity];
    } else {
        NSAssert(!validity, @"unexpected validity: %@", validity);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        NSNumber *NB = [dict objectForKey:@"NotBefore"];
        NSTimeInterval from = [NB doubleValue];
        _notBefore = [[NSDate alloc] initWithTimeIntervalSince1970:from];
        
        NSNumber *NA = [dict objectForKey:@"NotAfter"];
        NSTimeInterval to = [NA doubleValue];
        _notAfter = [[NSDate alloc] initWithTimeIntervalSince1970:to];
    }
    return self;
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

@end

#pragma mark -

@implementation DIMCAData

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // Issuer
        id issuer = [dict objectForKey:@"Issuer"];
        _issuer = [DIMCASubject subjectWithSubject:issuer];
        
        // Validity
        id validity = [dict objectForKey:@"Validity"];
        _validity = [DIMCAValidity validityWithValidity:validity];
        
        // Subject
        id subject = [dict objectForKey:@"Subject"];
        _subject = [DIMCASubject subjectWithSubject:subject];
        
        // Public Key
        id publicKey = [dict objectForKey:@"PublicKey"];
        _publicKey = [MKMPublicKey keyWithKey:publicKey];
    }
    return self;
}

@end

#pragma mark -

@implementation DIMCertificateAuthority

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // Version
        NSNumber *version = [dict objectForKey:@"Version"];
        _version = [version unsignedIntegerValue];
        
        // Serial Number
        _serialNumber = [dict objectForKey:@"SerialNumber"];
        
        // CA Data Info
        id info = [dict objectForKey:@"Info"];
        if ([info isKindOfClass:[DIMCAData class]]) {
            _info = info;
        } else if ([info isKindOfClass:[NSDictionary class]]) {
            _info = [[DIMCAData alloc] initWithDictionary:info];
        } else if ([info isKindOfClass:[NSString class]]) {
            _info = [[DIMCAData alloc] initWithJSONString:info];
        }
        
        // Signature
        id CT = [dict objectForKey:@"Signature"];
        if ([CT isKindOfClass:[NSData class]]) {
            _signature = CT;
        } else if ([CT isKindOfClass:[NSString class]]) {
            self.signature = [CT base64Decode];
        }
        
        // Extensions
        _extensions = [dict objectForKey:@"Extensions"];
    }
    return self;
}

- (void)setVersion:(NSUInteger)version {
    if (_version != version) {
        [_storeDictionary setObject:@(version) forKey:@"Version"];
        _version = version;
    }
}

- (void)setSerialNumber:(NSString *)serialNumber {
    if (serialNumber) {
        if (![_serialNumber isEqualToString:serialNumber]) {
            [_storeDictionary setObject:serialNumber forKey:@"SerialNumber"];
            _serialNumber = serialNumber;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"SerialNumber"];
        _serialNumber = nil;
    }
}

- (void)setInfo:(DIMCAData *)info {
    if (info) {
        if (![_info isEqualToDictionary:info]) {
            [_storeDictionary setObject:info forKey:@"Info"];
            _info = info;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"Info"];
        _info = nil;
    }
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        if (![_signature isEqualToData:signature]) {
            [_storeDictionary setObject:[signature base64Encode]
                                 forKey:@"Signature"];
            self.signature = signature;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"Signature"];
        _signature = nil;
    }
}

- (void)setExtensions:(NSMutableDictionary *)extensions {
    if (extensions) {
        if (![_extensions isEqualToDictionary:extensions]) {
            [_storeDictionary setObject:extensions forKey:@"Extensions"];
            _extensions = extensions;
        }
    } else {
        [_storeDictionary removeObjectForKey:@"Extensions"];
        _extensions = nil;
    }
}

@end
