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

// @"https://sechat.dim.chat/{ID}}/upload"
@property (strong, nonatomic) NSString *uploadAPI;

// @"https://sechat.dim.chat/download/{ID}/{filename}"
@property (strong, nonatomic) NSString *downloadAPI;

// @"https://sechat.dim.chat/avatar/{ID}/{filename}"
@property (strong, nonatomic) NSString *avatarAPI;

+ (instancetype)sharedInstance;

- (NSURL *)uploadEncryptedData:(NSData *)data
                      filename:(nullable NSString *)name
                        sender:(DIMID *)from;

- (nullable NSData *)downloadEncryptedDataFromURL:(NSURL *)url;

- (nullable NSData *)decryptDataFromURL:(NSURL *)url
                               filename:(NSString *)name
                                wityKey:(DIMSymmetricKey *)key;

- (BOOL)saveData:(NSData *)data filename:(NSString *)name;
- (NSData *)loadDataWithFilename:(NSString *)name;

- (BOOL)saveThumbnail:(NSData *)data filename:(NSString *)name;
- (NSData *)loadThumbnailWithFilename:(NSString *)name;

#pragma mark Avatar

- (NSURL *)uploadAvatar:(NSData *)data
               filename:(nullable NSString *)name
                 sender:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
