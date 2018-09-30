//
//  DIMMessageContent.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent : DIMDictionary

+ (instancetype)contentWithContent:(id)content;

@end

NS_ASSUME_NONNULL_END
