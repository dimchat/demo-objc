//
//  DIMMessageContent.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DIMMessageType) {
    DIMMessageType_Text  = 0x01, // 0000 0001
    DIMMessageType_Quote = 0x03, // 0000 0011
    
    DIMMessageType_File  = 0x10, // 0001 0000
    DIMMessageType_Image = 0x11, // 0001 0001
    DIMMessageType_Audio = 0x12, // 0001 0010
    DIMMessageType_Video = 0x13, // 0001 0011
    
    DIMMessageType_Page  = 0x20, // 0010 0000
};

@protocol DIMMessageContentDelegate <NSObject>

/**
 Upload the file data and return the CDN URL

 @param data - file data
 @param name - filename
 @return URL to the online resource
 */
- (NSString *)URLStringForFileData:(const NSData *)data
                          filename:(const NSString *)name;

@end

@interface DIMMessageContent : DIMDictionary

// message type: text, image, ...
@property (readonly, nonatomic) DIMMessageType type;

// random number to identify message content
@property (readonly, nonatomic) NSUInteger serialNumber;

// delegate to upload file data
@property (weak, nonatomic) id<DIMMessageContentDelegate> delegate;

+ (instancetype)contentWithContent:(id)content;

/**
 *  Text message: {
 *      type: 0x01,
 *      serial: 123,
 *
 *      text: "..."
 *  }
 */
- (instancetype)initWithText:(const NSString *)text;

/**
 *  File message: {
 *      type: 0x10,
 *      serial: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(fileContent)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name;

/**
 *  Image message: {
 *      type: 0x11,
 *      serial: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(image)
 *      snapshot: "...",    // base64(smallImage)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name;

/**
 *  Audio message: {
 *      type: 0x12,
 *      serial: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(audio)
 *      text: "...",        // Automatic Speech Recognition
 *  }
 */
- (instancetype)initWithAudioData:(const NSData *)data;

/**
 *  Video message: {
 *      type: 0x13,
 *      serial: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(video)
 *      snapshot: "...",    // base64(smallImage)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name;

/**
 *  Web Page message: {
 *      type: 0x20,
 *      serial: 123,
 *
 *      url: "https://...", // Page URL
 *      icon: "...",        // base64(icon)
 *      title: "...",
 *      desc: "..."
 *  }
 */
- (instancetype)initWithURLString:(const NSString *)url
                            title:(const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon;

@end

@interface DIMMessageContent (GroupMessage)

// GroupID for group message
@property (strong, nonatomic) const MKMID *group;

// SerialNumber for referenced reply in group chatting
@property (readonly, nonatomic) NSUInteger quoteNumber;

/**
 *  Quote text message: {
 *      type: 0x03,
 *      serial: 123,
 *
 *      text: "...",
 *      quote: 123   // referenced serial number of previous message
 *  }
 */
- (instancetype)initWithText:(const NSString *)text quote:(NSUInteger)sn;

@end

NS_ASSUME_NONNULL_END
