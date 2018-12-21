//
//  DIMServiceProvider.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;

@interface DIMServiceProvider : DIMDictionary {
    
    DIMCertificateAuthority *_CA;
    NSString *_name;
    DIMPublicKey *_publicKey;
}

@property (readonly, copy, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, strong, nonatomic) NSString *name; // CA.info.subject
@property (readonly, strong, nonatomic) DIMPublicKey *publicKey; // CA.info

@property (strong, nonatomic) NSURL *home; // home page URL

+ (instancetype)providerWithProvider:(id)provider;

- (instancetype)initWithCA:(const DIMCertificateAuthority *)CA;

- (BOOL)verifyStation:(const DIMStation *)station;

@end

#pragma mark Service Provider Data Source

@protocol DIMServiceProviderDataSource <NSObject>

- (NSInteger)numberOfStationsInServiceProvider:(const DIMServiceProvider *)SP;

- (DIMStation *)serviceProvider:(const DIMServiceProvider *)SP
                 stationAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
