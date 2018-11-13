//
//  DIMMessageContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum DIMMessageType
 *
 *  @abstract A flag to indicate what kind of message content this is.
 *
 *  @discussion A message is something send from one place to another one,
 *      it can be an instant message, a system command, or something else.
 *
 *      DIMMessageType_Text indicates this is a normal message with plaintext.
 *
 *      DIMMessageType_File indicates this is a file, it may include filename
 *      and file data, but usually the file data will encrypted and upload to
 *      somewhere and here is just a URL to retrieve it.
 *
 *      DIMMessageType_Image indicates this is an image, it may send the image
 *      data directly(encrypt the image data with Base64), but we suggest to
 *      include a URL for this image just like the 'File' message, of course
 *      you can get a snapshot of this image here.
 *
 *      DIMMessageType_Audio indicates this is a voice message, you can get
 *      a URL to retrieve the voice data just like the 'File' message.
 *
 *      DIMMessageType_Video indicates this is a video file.
 *
 *      DIMMessageType_Page indicates this is a web page.
 *
 *      DIMMessageType_Quote indicates this message has quoted another message
 *      and the message content should be a plaintext.
 *
 *      DIMMessageType_Command indicates this is a command message.
 *
 *      DIMMessageType_Forward indicates here contains a TOP-SECRET message
 *      which needs your help to redirect it to the true receiver.
 *
 *  Bits:
 *      0000 0001 - this message contains plaintext you can read.
 *      0000 0010 - this is a message you can see.
 *      0000 0100 - this is a message you can hear.
 *      0000 1000 - this is a message for the robot, not for human.
 *
 *      0001 0000 - this message's main part is in somewhere else.
 *      0010 0000 - this message contains the 3rd party content.
 *      0100 0000 - (RESERVED)
 *      1000 0000 - this is a message send by the system, not human.
 *
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, DIMMessageType) {
    DIMMessageType_Unknown = 0x00,
    DIMMessageType_Text    = 0x01, // 0000 0001
    
    DIMMessageType_File    = 0x10, // 0001 0000
    DIMMessageType_Image   = 0x12, // 0001 0010
    DIMMessageType_Audio   = 0x14, // 0001 0100
    DIMMessageType_Video   = 0x16, // 0001 0110
    
    DIMMessageType_Page    = 0x20, // 0010 0000
    
    // quote a message before and reply it with text
    DIMMessageType_Quote   = 0x37, // 0011 0111
    
    DIMMessageType_Command = 0x88, // 1000 1000
    
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
 *      type : 0x01,
 *      sn   : 123,
 *
 *      text : "..."
 *  }
 */
- (instancetype)initWithText:(const NSString *)text;

#pragma mark - File message

@property (readonly, strong, nonatomic, nullable) NSURL *URL;
@property (readonly, strong, nonatomic, nullable) NSData *fileData;
@property (readonly, strong, nonatomic, nullable) NSString *filename;

/**
 *  File message: {
 *      type : 0x10,
 *      sn   : 123,
 *
 *      URL      : "https://...", // upload to CDN
 *      data     : "...",         // if (!URL) base64(fileContent)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name;

#pragma mark Image message

@property (readonly, strong, nonatomic, nullable) NSData *imageData;
@property (readonly, strong, nonatomic, nullable) NSData *snapshot;

/**
 *  Image message: {
 *      type : 0x12,
 *      sn   : 123,
 *
 *      URL      : "https://...", // upload to CDN
 *      data     : "...",         // if (!URL) base64(image)
 *      snapshot : "...",         // base64(smallImage)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark Audio message

@property (readonly, strong, nonatomic, nullable) NSData *audioData;

/**
 *  Audio message: {
 *      type : 0x14,
 *      sn   : 123,
 *
 *      URL      : "https://...", // upload to CDN
 *      data     : "...",         // if (!URL) base64(audio)
 *      text     : "...",         // Automatic Speech Recognition
 *      filename : "..."
 *  }
 */
- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark Video message

@property (readonly, strong, nonatomic, nullable) NSData *videoData;

/**
 *  Video message: {
 *      type : 0x16,
 *      sn   : 123,
 *
 *      URL      : "https://...", // upload to CDN
 *      data     : "...",         // if (!URL) base64(video)
 *      snapshot : "...",         // base64(smallImage)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name;

#pragma mark - Webpage message

@property (readonly, strong, nonatomic, nullable) NSString *title;
@property (readonly, strong, nonatomic, nullable) NSString *desc;
@property (readonly, strong, nonatomic, nullable) NSData *icon;

/**
 *  Web Page message: {
 *      type : 0x20,
 *      sn   : 123,
 *
 *      URL   : "https://...", // Page URL
 *      icon  : "...",         // base64(icon)
 *      title : "...",
 *      desc  : "..."
 *  }
 */
- (instancetype)initWithURLString:(const NSString *)url
                            title:(nullable const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon;

@end

#pragma mark - Group message content

@interface DIMMessageContent (GroupMessage)

// SerialNumber for referenced reply in group chatting
@property (readonly, nonatomic) NSUInteger quoteNumber;

/**
 *  Quote text message: {
 *      type : 0x37,
 *      sn   : 123,
 *
 *      text  : "...",
 *      quote : 123   // referenced serial number of previous message
 *  }
 */
- (instancetype)initWithText:(const NSString *)text quote:(NSUInteger)sn;

@end

NS_ASSUME_NONNULL_END
