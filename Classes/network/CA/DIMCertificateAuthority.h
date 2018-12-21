//
//  DIMCertificateAuthority.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

#import "DIMCASubject.h"
#import "DIMCAValidity.h"
#import "DIMCAData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCertificateAuthority : DIMDictionary

@property (nonatomic) NSUInteger version;
@property (strong, nonatomic) NSString *serialNumber;

@property (copy, nonatomic) DIMCAData *info; // JsON String

@property (copy, nonatomic) NSData *signature; // signed by Issuer

@property (readonly, strong, nonatomic) NSMutableDictionary *extensions;

+ (instancetype)caWithCA:(id)ca;

- (BOOL)verifyWithPublicKey:(const DIMPublicKey *)PK;

- (void)setExtraValue:(id)value forKey:(const NSString *)key;

@end

NS_ASSUME_NONNULL_END
