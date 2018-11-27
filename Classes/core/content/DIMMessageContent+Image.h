//
//  DIMMessageContent+Image.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent (Image)

@property (readonly, strong, nonatomic) NSData *imageData;
@property (readonly, strong, nonatomic, nullable) NSData *snapshot;

/**
 *  Image message: {
 *      type : 0x12,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64(image)
 *      snapshot : "...",     // base64(smallImage)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name;

@end

NS_ASSUME_NONNULL_END
