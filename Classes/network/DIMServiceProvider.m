//
//  DIMServiceProvider.m
//  DIM
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMCertificateAuthority.h"
#import "DIMStation.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

- (instancetype)initWithCA:(const DIMCertificateAuthority *)CA {
    if (self = [self init]) {
        // CA
        _CA = [CA copy];
        
        // name
        if (_CA.info.subject.commonName) {
            _name = _CA.info.subject.commonName;
        } else {
            _name = _CA.info.subject.organization;
        }
        
        // public key
        _publicKey = _CA.info.publicKey;
        
        // stations
        _stations = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Station

- (BOOL)verifyStation:(const DIMStation *)station {
    // CA.info -> data
    DIMCertificateAuthority *CA = station.CA;
    NSString *json = [CA.info jsonString];
    NSData *data = [json data];
    // verify the signature
    return [_publicKey verify:data withSignature:CA.signature];
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
