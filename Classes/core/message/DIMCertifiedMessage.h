//
//  DIMCertifiedMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMSecureMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCertifiedMessage : DIMSecureMessage

@property (readonly, strong, nonatomic) const NSData *signature;

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to
                            key:(const MKMSymmetricKey *)key
                      signature:(const NSData *)CT
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
