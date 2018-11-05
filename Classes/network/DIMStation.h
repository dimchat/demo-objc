//
//  DIMStation.h
//  DIMC
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMStation : NSObject

@property (readonly, strong, nonatomic) NSString *host; // Domain/IP
@property (readonly, nonatomic) NSUInteger port;        // default: 9527

@property (strong, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) MKMPublicKey *publicKey;

- (instancetype)initWithHost:(const NSString *)host;

- (instancetype)initWithHost:(const NSString *)host port:(NSUInteger)port
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
