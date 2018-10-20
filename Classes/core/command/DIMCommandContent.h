//
//  DIMCommandContent.h
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommandContent : DIMDictionary

+ (instancetype)commandWithCommand:(id)cmd;

@end

NS_ASSUME_NONNULL_END
