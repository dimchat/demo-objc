//
//  DIMFileServer.h
//  DIMClient
//
//  Created by Albert Moky on 2019/4/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMFileServer : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic, nullable) NSString *userAgent; // default is nil

// @"http://124.156.108.150:8081/{ID}}/upload"
@property (strong, nonatomic) NSString *uploadAPI;

// @"http://124.156.108.150:8081/download/{ID}/{filename}"
@property (strong, nonatomic) NSString *downloadAPI;

// @"http://124.156.108.150:8081/{ID}/avatar.{ext}"
@property (strong, nonatomic) NSString *avatarAPI;

+ (instancetype)sharedInstance;

- (NSURL *)uploadEncryptedData:(const NSData *)data
                      filename:(nullable const NSString *)name
                        sender:(const DIMID *)from;

- (nullable NSData *)downloadEncryptedDataFromURL:(const NSURL *)url;

- (nullable NSData *)decryptDataFromURL:(const NSURL *)url
                               filename:(const NSString *)name
                                wityKey:(const DIMSymmetricKey *)key;

- (BOOL)saveData:(const NSData *)data filename:(const NSString *)name;
- (NSData *)loadDataWithFilename:(const NSString *)name;

- (BOOL)saveThumbnail:(const NSData *)data filename:(const NSString *)name;
- (NSData *)loadThumbnailWithFilename:(const NSString *)name;

#pragma mark Avatar

- (NSURL *)uploadAvatar:(const NSData *)data
               filename:(nullable const NSString *)name
                 sender:(const DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
