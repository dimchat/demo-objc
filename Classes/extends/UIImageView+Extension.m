//
//  UIImageView+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/5.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIImage+Extension.h"

#import "UIImageView+Extension.h"

@implementation UIView (Extension)

- (void)roundedCorner {
    CGRect rect = self.bounds;
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                     byRoundingCorners:UIRectCornerAllCorners
                                           cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end

@implementation UIImageView (Extension)

- (void)setText:(NSString *)text {
    [self setText:text color:nil backgroundColor:nil];
}

- (void)setText:(NSString *)text color:(nullable UIColor *)textColor backgroundColor:(nullable UIColor *)bgColor {
    CGSize size = self.bounds.size;
    UIImage *image = [UIImage imageWithText:text size:size color:textColor backgroundColor:bgColor];
    [self setImage:image];
}

@end
