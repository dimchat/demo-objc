//
//  DKDMessageContent+Audio.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDMessageContent (Audio)

@property (readonly, strong, nonatomic) NSData *audioData;

/**
 *  Audio message: {
 *      type : 0x14,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64_encode(audio)
 *      text     : "...",     // Automatic Speech Recognition
 *      filename : "..."
 *  }
 */
- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name;

@end

NS_ASSUME_NONNULL_END
