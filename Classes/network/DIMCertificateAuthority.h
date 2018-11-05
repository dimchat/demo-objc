//
//  DIMCertificateAuthority.h
//  DIMC
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCASubject : DIMDictionary

@property (strong, nonatomic) NSString *country;  // C:  CN, US, ...
@property (strong, nonatomic) NSString *state;    // ST: province
@property (strong, nonatomic) NSString *locality; // L:  city

@property (strong, nonatomic) NSString *organization;     // O:  Co., Ltd.
@property (strong, nonatomic) NSString *organizationUnit; // OU: Department
@property (strong, nonatomic) NSString *commonName;       // CN: domain/ip

+ (instancetype)subjectWithSubject:(id)subject;

@end

#pragma mark -

@interface DIMCAValidity : DIMDictionary

@property (readonly, strong, nonatomic) NSDate *notBefore;
@property (readonly, strong, nonatomic) NSDate *notAfter;

+ (instancetype)validityWithValidity:(id)validity;

- (instancetype)initWithNotBefore:(const NSDate *)from
                         notAfter:(const NSDate *)to;

@end

#pragma mark -

/**
 CA data
 */
@interface DIMCAData : DIMDictionary

@property (strong, nonatomic) DIMCASubject *issuer; // issuer DN

@property (strong, nonatomic) DIMCAValidity *validity;

@property (strong, nonatomic) DIMCASubject *subject; // the CA owner
@property (strong, nonatomic) MKMPublicKey *publicKey; // owner's PK

@end

#pragma mark -

/**
 Certificate Authority
 */
@interface DIMCertificateAuthority : DIMDictionary

@property (nonatomic) NSUInteger version;
@property (strong, nonatomic) NSString *serialNumber;

@property (strong, nonatomic) DIMCAData *info; // JsON String

@property (strong, nonatomic) NSData *signature; // signed by Issuer

@property (strong, nonatomic) NSMutableDictionary *extensions;

@end

NS_ASSUME_NONNULL_END
