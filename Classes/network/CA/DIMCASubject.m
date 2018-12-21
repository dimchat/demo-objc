//
//  DIMCASubject.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCASubject.h"

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
