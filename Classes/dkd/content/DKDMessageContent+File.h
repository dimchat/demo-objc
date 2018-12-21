//
//  DKDMessageContent+File.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDMessageContent (File)

// URL for download the file data from CDN
@property (readonly, strong, nonatomic, nullable) NSURL *URL;

@property (readonly, strong, nonatomic) NSData *fileData;
@property (readonly, strong, nonatomic, nullable) NSString *filename;

/**
 *  File message: {
 *      type : 0x10,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64_encode(fileContent)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name;

@end

NS_ASSUME_NONNULL_END
