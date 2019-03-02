//
//  UIImage+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)

+ (UIImage *)imageWithURLString:(const NSString *)urlString;

+ (UIImage *)imageWithText:(const NSString *)text size:(const CGSize)size;

- (UIImage *)resizableImage;

@end

NS_ASSUME_NONNULL_END
