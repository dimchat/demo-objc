//
//  DIMCAValidity.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCAValidity : DIMDictionary

@property (copy, nonatomic) NSDate *notBefore;
@property (copy, nonatomic) NSDate *notAfter;

+ (instancetype)validityWithValidity:(id)validity;

- (instancetype)initWithNotBefore:(const NSDate *)from
                         notAfter:(const NSDate *)to;

@end

NS_ASSUME_NONNULL_END
