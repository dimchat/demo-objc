//
//  UIImageView+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/5.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#include <TargetConditionals.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
// TODO:
#else
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extension)

- (void)roundedCorner;

@end

@interface UIImageView (Extension)

// set image with text
- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text color:(nullable UIColor *)textColor backgroundColor:(nullable UIColor *)bgColor;

@end

NS_ASSUME_NONNULL_END

#endif
