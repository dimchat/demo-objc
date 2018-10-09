//
//  DIMContact.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMInstantMessage;
@class DIMSecureMessage;
@class DIMCertifiedMessage;

@protocol DIMContact <MKMPublicKey>

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg;

- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)msg;

@end

@interface DIMContact : MKMContact <DIMContact>

@property (readonly, strong, nonatomic) const MKMSymmetricKey *passphrase;

@end

NS_ASSUME_NONNULL_END
