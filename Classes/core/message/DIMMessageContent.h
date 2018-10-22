//
//  DIMMessageContent.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMMessageType) {
    DIMMessageType_Text    = 0x01, // 0000 0001
    
    DIMMessageType_File    = 0x10, // 0001 0000
    DIMMessageType_Image   = 0x12, // 0001 0010
    DIMMessageType_Audio   = 0x14, // 0001 0100
    DIMMessageType_Video   = 0x16, // 0001 0110
    
    DIMMessageType_Page    = 0x20, // 0010 0000
    
    // quote a message before and reply it with text
    DIMMessageType_Quote   = 0x31, // 0011 0001
    
    // top-secret message forward by proxy (Service Provider)
    DIMMessageType_Forward = 0xFF  // 1111 1111
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

// Group ID for group message
@property (strong, nonatomic, nullable) MKMID *group;

// delegate to upload file data
@property (weak, nonatomic) id<DIMMessageContentDelegate> delegate;

+ (instancetype)contentWithContent:(id)content;

#pragma mark - Text message

@property (readonly, strong, nonatomic) NSString *text;

/**
 *  Text message: {
 *      type: 0x01,
 *      sn: 123,
 *
 *      text: "..."
 *  }
 */
- (instancetype)initWithText:(const NSString *)text;

#pragma mark - File message

@property (readonly, strong, nonatomic) NSData *fileData;
@property (readonly, strong, nonatomic, nullable) NSString *filename;

/**
 *  File message: {
 *      type: 0x10,
 *      sn: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(fileContent)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name;

#pragma mark Image message

@property (readonly, strong, nonatomic) NSData *imageData;
@property (readonly, strong, nonatomic, nullable) NSData *snapshot;

/**
 *  Image message: {
 *      type: 0x11,
 *      sn: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(image)
 *      snapshot: "...",    // base64(smallImage)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark Audio message

@property (readonly, strong, nonatomic) NSData *audioData;

/**
 *  Audio message: {
 *      type: 0x12,
 *      sn: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(audio)
 *      text: "...",        // Automatic Speech Recognition
 *      filename: "..."
 *  }
 */
- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark Video message

@property (readonly, strong, nonatomic) NSData *videoData;

/**
 *  Video message: {
 *      type: 0x13,
 *      sn: 123,
 *
 *      url: "https://...", // upload to CDN
 *      data: "...",        // if (!url) base64(video)
 *      snapshot: "...",    // base64(smallImage)
 *      filename: "..."
 *  }
 */
- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark - Webpage message

@property (readonly, strong, nonatomic) NSString *URLString;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic, nullable) NSString *desc;
@property (readonly, strong, nonatomic, nullable) NSData *icon;

/**
 *  Web Page message: {
 *      type: 0x20,
 *      sn: 123,
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

#pragma mark - Group message content

@interface DIMMessageContent (GroupMessage)

// SerialNumber for referenced reply in group chatting
@property (readonly, nonatomic) NSUInteger quoteNumber;

/**
 *  Quote text message: {
 *      type: 0x31,
 *      sn: 123,
 *
 *      text: "...",
 *      quote: 123   // referenced serial number of previous message
 *  }
 */
- (instancetype)initWithText:(const NSString *)text quote:(NSUInteger)sn;

@end

NS_ASSUME_NONNULL_END
