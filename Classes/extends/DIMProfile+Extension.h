//
//  DIMProfile+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/2.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMProfile (Extension)

// account.avatar
- (UIImage *)avatarImageWithSize:(const CGSize)size;

// group.logo
- (UIImage *)logoImageWithSize:(const CGSize)size;

@end

NS_ASSUME_NONNULL_END

#endif
