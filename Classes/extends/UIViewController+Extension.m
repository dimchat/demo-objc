//
//  UIViewController+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIViewController+Extension.h"

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
// TODO:
#else

@implementation UIViewController (Extension)

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    
    [self showMessage:text withTitle:title defaultButton:@"OK"];
}

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      defaultButton:(nullable NSString *)defaultTitle {
    
    UIAlertController * alert;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:text
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OK;
    OK = [UIAlertAction actionWithTitle:defaultTitle
                                  style:UIAlertActionStyleDefault
                                handler:nil];
    [alert addAction:OK];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      cancelHandler:(void (^)(UIAlertAction *))cancelHandler
     defaultHandler:(void (^)(UIAlertAction *))okHandler {
    
    [self showMessage:text
            withTitle:title
        cancelHandler:cancelHandler
          cacelButton:@"Cancel"
       defaultHandler:okHandler
        defaultButton:@"OK"];
}

- (void)showMessage:(nullable NSString *)text
          withTitle:(nullable NSString *)title
      cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
        cacelButton:(nullable NSString *)cancelTitle
     defaultHandler:(void (^ __nullable)(UIAlertAction *action))okHandler
      defaultButton:(nullable NSString *)defaultTitle {
    
    UIAlertController * alert;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:text
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction;
    cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                      style:UIAlertActionStyleCancel
                                    handler:cancelHandler];
    UIAlertAction *okAction;
    okAction = [UIAlertAction actionWithTitle:defaultTitle
                                        style:UIAlertActionStyleDefault
                                      handler:okHandler];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

#endif
