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

@protocol DIMContact <MKMPublicKey>

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)message;

@end

@interface DIMContact : MKMContact <DIMContact>

@end

NS_ASSUME_NONNULL_END
