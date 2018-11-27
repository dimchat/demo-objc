//
//  DIMMessageContent+Webpage.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent (Webpage)

@property (readonly, strong, nonatomic, nullable) NSString *title;
@property (readonly, strong, nonatomic, nullable) NSString *desc;
@property (readonly, strong, nonatomic, nullable) NSData *icon;

/**
 *  Web Page message: {
 *      type : 0x20,
 *      sn   : 123,
 *
 *      URL   : "https://github.com/moky/dimp", // Page URL
 *      icon  : "...",                          // base64(icon)
 *      title : "...",
 *      desc  : "..."
 *  }
 */
- (instancetype)initWithURLString:(const NSString *)url
                            title:(nullable const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon;

@end

NS_ASSUME_NONNULL_END
