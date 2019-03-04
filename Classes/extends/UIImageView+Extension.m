//
//  UIImageView+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/5.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)

- (void)roundedCorner {
    if (self.layer.mask) {
        return ;
    }
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
