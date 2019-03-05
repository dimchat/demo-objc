//
//  UIStoryboardSegue+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIStoryboardSegue+Extension.h"

@implementation UIStoryboardSegue (Extension)

- (UIViewController *)visibleDestinationViewController {
    UIViewController *vc = self.destinationViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc visibleViewController];
    } else {
        return vc;
    }
}

@end
