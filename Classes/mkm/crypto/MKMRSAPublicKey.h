//
//  MKMRSAPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

NS_ASSUME_NONNULL_BEGIN

SecKeyRef SecKeyRefFromNSData(const NSData *data, BOOL isPublic);
NSData *NSDataFromSecKeyRef(SecKeyRef keyRef);

NSString *RSAPublicKeyDataFromNSString(const NSString *content);
NSString *RSAPrivateKeyDataFromNSString(const NSString *content);

/**
 *  RSA Public Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA",
 *          data: "..."       // base64
 *      }
 */
@interface MKMRSAPublicKey : MKMPublicKey

@end

NS_ASSUME_NONNULL_END
