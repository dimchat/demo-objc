//
//  DIMProfile+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/2.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIImage+Extension.h"

#import "DIMProfile+Extension.h"

@implementation DIMProfile (Extension)

- (UIImage *)avatarImageWithSize:(const CGSize)size {
    UIImage *image = nil;
    NSString *avatar = self.avatar;
    if (avatar) {
        if ([avatar containsString:@"://"]) {
            image = [UIImage imageWithURLString:avatar];
        } else {
            image = [UIImage imageNamed:avatar];
        }
    }
    if (!image) {
        NSString *name = self.name;
        if (name.length == 0) {
            name = self.ID.name;
            if (name.length == 0) {
                name = @"Đ"; // BTC Address: ฿
            }
        }
        if (name.length > 0) {
            NSString *text = [name substringToIndex:1];
            image = [UIImage imageWithText:text size:size];
        }
    }
    return image;
}

@end
