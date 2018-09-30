//
//  DIMInstantMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMMessageContent;

@interface DIMInstantMessage : DIMDictionary

@property (readonly, strong, nonatomic) const MKMID *sender;
@property (readonly, strong, nonatomic) const MKMID *receiver;
@property (readonly, strong, nonatomic) const NSDate *time;

@property (readonly, strong, nonatomic) const DIMMessageContent *content;

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
