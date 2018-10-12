//
//  DIMServiceProvider.m
//  DIM
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

- (instancetype)initWithCA:(const DIMCertificateAuthority *)CA {
    if (self = [self init]) {
        _CA = [CA copy];
        
        _stations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)name {
    NSString *str = _CA.info.subject.commonName;
    if (!str) {
        str = _CA.info.subject.organization;
    }
    return str;
}

- (MKMPublicKey *)publicKey {
    return _CA.info.publicKey;
}

#pragma mark Station

- (BOOL)verifyStation:(const DIMStation *)station {
    // CA.info -> data
    DIMCertificateAuthority *CA = station.CA;
    NSString *json = [CA.info jsonString];
    NSData *data = [json data];
    // public key
    MKMPublicKey *PK = self.publicKey;
    // verify the signature
    return [PK verify:data signature:CA.signature];
}

- (void)addStation:(DIMStation *)station {
    if ([_stations containsObject:station]) {
        return ;
    }
    if ([self verifyStation:station]) {
        // signature correct
        [_stations addObject:station];
        return ;
    }
    NSAssert(false, @"add station failed");
}

- (void)removeStation:(DIMStation *)station {
    NSAssert([_stations containsObject:station], @"not found");
    [_stations removeObject:station];
}

@end
