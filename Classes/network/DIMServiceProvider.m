//
//  DIMServiceProvider.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

#import "DIMServiceProvider.h"

@interface DIMServiceProvider ()

@property (copy, nonatomic) DIMCertificateAuthority *CA;

@end

@implementation DIMServiceProvider

+ (instancetype)providerWithProvider:(id)provider {
    if ([provider isKindOfClass:[DIMServiceProvider class]]) {
        return provider;
    } else if ([provider isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:provider];
    } else if ([provider isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:provider];
    } else {
        NSAssert(!provider, @"unexpected provider: %@", provider);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [super init];
    return self;
}

- (instancetype)initWithCA:(const DIMCertificateAuthority *)CA {
    NSDictionary *dict = @{@"CA":CA};
    if (self = [self initWithDictionary:dict]) {
        // CA
        _CA = [CA copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMServiceProvider *SP = [super copyWithZone:zone];
    if (SP) {
        SP.CA = _CA;
        SP.home = _home;
    }
    return SP;
}

- (DIMCertificateAuthority *)CA {
    if (!_CA) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"CA"];
        _CA = [DIMCertificateAuthority caWithCA:dict];
    }
    return _CA;
}

- (NSString *)name {
    DIMCASubject *subject = self.CA.info.subject;
    if (subject.commonName) {
        return subject.commonName;
    } else {
        return subject.organization;
    }
}

- (DIMPublicKey *)publicKey {
    return self.CA.info.publicKey;
}

#pragma mark Station

- (BOOL)verifyStation:(const DIMStation *)station {
    DIMCertificateAuthority *CA = station.CA;
    return [CA verifyWithPublicKey:self.publicKey];
}

@end
