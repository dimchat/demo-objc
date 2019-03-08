//
//  UIViewController+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extension)

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title;

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      defaultButton:(nullable NSString *)defaultTitle;

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
     defaultHandler:(void (^ __nullable)(UIAlertAction *action))okHandler;

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
        cacelButton:(nullable NSString *)cancelTitle
     defaultHandler:(void (^ __nullable)(UIAlertAction *action))okHandler
      defaultButton:(nullable NSString *)defaultTitle;

@end

NS_ASSUME_NONNULL_END
