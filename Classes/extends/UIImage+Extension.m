//
//  UIImage+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSString+Extension.h"

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

+ (UIImage *)imageWithURLString:(const NSString *)urlString {
    NSURL *url = [NSURL URLWithString:[urlString copy]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        return [UIImage imageWithData:data];
    } else {
        NSLog(@"failed to get image data from: %@", urlString);
        return nil;
    }
}

+ (UIImage *)imageWithText:(const NSString *)text size:(const CGSize)size {
    UIColor *bgColor = [UIColor grayColor];
    UIColor *textColor = [UIColor whiteColor];
    
    // prepare image contact
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // calculate font size
    CGFloat fontSize = [UIFont systemFontSize];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize textSize = [text sizeWithFont:font maxSize:size];
    CGFloat scale = MIN(size.width / textSize.width,
                        size.height / textSize.height);
    // adjust text font size
    fontSize *= scale;
    font = [UIFont systemFontOfSize:fontSize];
    textSize = [text sizeWithFont:font maxSize:size];
    
    // draw the text in center
    NSDictionary *attr = @{NSFontAttributeName:font,
                           NSForegroundColorAttributeName:textColor,
                           };
    CGRect rect = CGRectMake((size.width - textSize.width) * 0.5,
                             (size.height - textSize.height) * 0.5,
                             size.width, size.height);
    [text drawInRect:rect withAttributes:attr];
    
    // get image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)resizableImage {
    CGSize size = self.size;
    CGFloat x = size.width * 0.75;
    CGFloat y = size.height * 0.75;
    /* CGFloat top, CGFloat left, CGFloat bottom, CGFloat right */
    UIEdgeInsets insets = UIEdgeInsetsMake(y, x, y + 1, x + 1);
    return [self resizableImageWithCapInsets:insets];
}

@end
