//
//  MKMRSAKeyHelper.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

SecKeyRef SecKeyRefFromPublicData(const NSData *data);
SecKeyRef SecKeyRefFromPrivateData(const NSData *data);

NSData *NSDataFromSecKeyRef(SecKeyRef keyRef);

NSString *RSAPublicKeyContentFromNSString(const NSString *content);
NSString *RSAPrivateKeyContentFromNSString(const NSString *content);

NS_ASSUME_NONNULL_END
