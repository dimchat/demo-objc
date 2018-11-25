//
//  MKMRSAPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

NS_ASSUME_NONNULL_BEGIN

SecKeyRef SecKeyRefFromPublicData(const NSData *data);
SecKeyRef SecKeyRefFromPrivateData(const NSData *data);

NSData *NSDataFromSecKeyRef(SecKeyRef keyRef);

NSString *RSAPublicKeyContentFromNSString(const NSString *content);
NSString *RSAPrivateKeyContentFromNSString(const NSString *content);

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
