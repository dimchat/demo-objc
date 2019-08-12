//
//  MKMUser+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/8/12.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMLocalUser (Extension)

+ (nullable instancetype)userWithConfigFile:(NSString *)config;

@end

NS_ASSUME_NONNULL_END
