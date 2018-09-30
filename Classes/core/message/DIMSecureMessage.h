//
//  DIMSecureMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMSecureMessage : DIMInstantMessage

@property (readonly, strong, nonatomic) const MKMSymmetricKey *scKey;

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to
                            key:(const MKMSymmetricKey *)key
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
