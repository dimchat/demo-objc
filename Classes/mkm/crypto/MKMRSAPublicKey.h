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

NSString *RSAKeyDataFromNSString(const NSString *content, BOOL isPublic);

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
