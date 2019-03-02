//
//  UIViewController+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    
    UIAlertController * alert;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:text
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OK;
    OK = [UIAlertAction actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                handler:nil];
    [alert addAction:OK];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
      cancelHandler:(void (^ __nullable)(UIAlertAction *))cancelHandler
     defaultHandler:(void (^ __nullable)(UIAlertAction *))okHandler {
    
    UIAlertController * alert;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:text
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction;
    cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleCancel
                                    handler:cancelHandler];
    UIAlertAction *okAction;
    okAction = [UIAlertAction actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                      handler:okHandler];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
