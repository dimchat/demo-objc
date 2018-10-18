//
//  DIMServiceProvider.h
//  DIM
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMCertificateAuthority;
@class DIMStation;

@interface DIMServiceProvider : NSObject {
    
    NSMutableArray<DIMStation *> *_stations;
}

@property (readonly, strong, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) MKMPublicKey *publicKey;

@property (readonly, strong, nonatomic) NSArray<DIMStation *> *stations;

@property (strong, nonatomic) NSURL *home; // home page URL

- (instancetype)initWithCA:(const DIMCertificateAuthority *)CA;

- (BOOL)verifyStation:(const DIMStation *)station;

- (void)addStation:(DIMStation *)station;
- (void)removeStation:(DIMStation *)station;

@end

NS_ASSUME_NONNULL_END
