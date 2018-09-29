//
//  MKMContact.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMContact : MKMAccount

@property (readonly, strong, nonatomic) const NSString *name;
@property (readonly, strong, nonatomic) const NSString *avatar; // URL

@end

NS_ASSUME_NONNULL_END
