//
//  DIMMessageContent+Video.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageContent (Video)

@property (readonly, strong, nonatomic, nullable) NSData *videoData;

/**
 *  Video message: {
 *      type : 0x16,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64(video)
 *      snapshot : "...",     // base64(smallImage)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name;

@end

NS_ASSUME_NONNULL_END
