// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMFileServer.m
//  DIMP
//
//  Created by Albert Moky on 2019/4/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFileServer.h"

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

static inline void make_dirs(NSString *dir) {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

static inline BOOL remove_file(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSError *err = nil;
        [fm removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"failed to remove file: %@", err);
            return NO;
        }
    }
    return YES;
}

#pragma mark Paths

/**
 Get data filepath in Caches Directory
 
 @param filename - "xxxx.png"
 @return "Library/Caches/.dkd/files/xxxx.png"
 */
static inline NSString *data_filepath(NSString *filename, BOOL autoCreate) {
    // base directory: Library/Caches/.dkd/files
    NSString *dir = caches_directory();
    dir = [dir stringByAppendingPathComponent:@".dkd"];
    dir = [dir stringByAppendingPathComponent:@"files"];
    
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

/**
 Get thumbnail filepath in Documents Directory
 
 @param filename - "xxxx.png"
 @return "Documents/.dkd/thumbnail/xxxx.png"
 */
static inline NSString *thumbnail_filepath(NSString *filename, BOOL autoCreate) {
    // base directory: Documents/.dkd/thumbnail
    NSString *dir = document_directory();
    dir = [dir stringByAppendingPathComponent:@".dkd"];
    dir = [dir stringByAppendingPathComponent:@"thumbnail"];
    
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

#pragma mark -

@interface DIMFileServer () {
    
    NSString *_uploadAPI;
    NSString *_downloadAPI;
    
    NSMutableDictionary *_uploadings;
    NSMutableDictionary *_downloadings;
}

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation DIMFileServer

SingletonImplementations(DIMFileServer, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
        // @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
        _userAgent = nil;
        
        _uploadAPI = nil;
        _downloadAPI = nil;
        
       _uploadings  = [[NSMutableDictionary alloc] init];
        _downloadings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                                didSendBodyData:(int64_t)bytesSent
                                 totalBytesSent:(int64_t)totalBytesSent
                       totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    float progress = (float)totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"progress %f%%", progress * 100);
    
    // finished
    if (totalBytesSent == totalBytesExpectedToSend) {
        NSLog(@"task finished: %@", task);
    }
}

#pragma mark NSURLSession

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config;
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.0f;
        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        if (_userAgent.length > 0) {
            config.HTTPAdditionalHeaders = @{@"User-Agent": _userAgent};
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }
    return _session;
}

#define C_BOUNDARY              "BU1kUJ19yLYPqv5xoT3sbKYbHwjUu1JU7roix"
#define C_CONTENT_TYPE          "multipart/form-data; boundary=" C_BOUNDARY
#define C_BOUNDARY_BEGIN        "--" C_BOUNDARY "\r\n"                      \
                "Content-Disposition: form-data; name=%@; filename=%@\r\n"  \
                "Content-Type: application/octet-stream\r\n\r\n"
#define C_BOUNDARY_END          "\r\n--" C_BOUNDARY "--"

#define CONTENT_TYPE   [NSString stringWithCString:(C_CONTENT_TYPE) encoding:NSUTF8StringEncoding]
#define BOUNDARY_BEGIN [NSString stringWithCString:(C_BOUNDARY_BEGIN) encoding:NSUTF8StringEncoding]
#define BOUNDARY_END   [NSString stringWithCString:(C_BOUNDARY_END) encoding:NSUTF8StringEncoding]

- (NSData *)buildHTTPBodyWithFilename:(NSString *)name
                              varName:(NSString *)var
                                 data:(NSData *)data {
    NSString *begin = [NSString stringWithFormat:BOUNDARY_BEGIN, var, name];    
    NSString *end = BOUNDARY_END;
    
    NSUInteger len = begin.length + data.length + end.length;
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:len];
    [mData appendData:MKMUTF8Encode(begin)];
    [mData appendData:data];
    [mData appendData:MKMUTF8Encode(end)];
    return mData;
}

- (void)post:(NSData *)data name:(NSString *)filename varName:(NSString *)var url:(NSURL *)url {
    
    // check uploading queue
    if ([_uploadings objectForKey:filename]) {
        NSAssert(false, @"post twice: %@", filename);
        return;
    }
    
    // URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    // HTTP body
    NSData *body = [self buildHTTPBodyWithFilename:filename varName:var data:data];
    
    // completion handler
    void (^handler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
    handler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"HTTP upload task complete: %@, %@, %@", response, error, MKMUTF8Decode(data));
        
        if (error) {
            // connection error
            NSLog(@"upload %@ error: %@", url, error);
        } else {
            // TODO: post notice 'EncryptedFileUploaded'
        }
        
        // remove uploading task
        NSLog(@"removing task: %@, filename: %@", [self->_uploadings objectForKey:filename], filename);
        [self->_uploadings removeObjectForKey:filename];
    };
    
    // upload task
    NSURLSessionUploadTask *task;
    task = [self.session uploadTaskWithRequest:request fromData:body completionHandler:handler];
    // add to queue
    [_uploadings setObject:task forKey:filename];
    
    // start
    [task resume];
}

- (void)get:(NSURL *)url name:(NSString *)filename {
    
    // check downloading queue
    if ([_downloadings objectForKey:filename]) {
        NSLog(@"waiting for download: %@", filename);
        return ;
    }
    
    // completion handler
    void (^handler)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);
    handler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"HTTP download task complete: %@, %@, %@", response, error, location);
        
        if (error) {
            // connection error
            NSLog(@"download %@ error: %@", url, error);
        } else if ([response.MIMEType isEqualToString:@"text/html"]) {
            // server response error
            NSData *data = [NSData dataWithContentsOfURL:location];
            NSLog(@"download %@ error: %@", url, MKMUTF8Decode(data));
        } else {
            // move to caches directory
            NSFileManager *fm = [NSFileManager defaultManager];
            NSURL *path = [NSURL fileURLWithPath:data_filepath(filename, YES)];
            if ([fm moveItemAtURL:location toURL:path error:&error]) {
                NSLog(@"download success: %@", path);
            } else {
                NSLog(@"download error: %@", error);
            }
            // TODO: post notice 'EncryptedFileDownloaded'
        }
        
        // remove downloading task
        NSLog(@"removing task: %@, filename: %@", [self->_downloadings objectForKey:filename], filename);
        [self->_downloadings removeObjectForKey:filename];
    };
    
    NSURLSessionDownloadTask *task;
    task = [self.session downloadTaskWithURL:url completionHandler:handler];
    // add to queue
    [_downloadings setObject:task forKey:filename];
    
    // start
    [task resume];
}

#pragma mark -

- (NSURL *)uploadEncryptedData:(NSData *)data
                      filename:(nullable NSString *)name
                        sender:(id<MKMID>)from {
    
    // prepare filename (make sure that filenames won't conflict)
    NSString *filename = MKMHexEncode(MKMMD5Digest(data));
    NSString *ext = [name pathExtension];
    if (ext.length > 0) {
        filename = [filename stringByAppendingPathExtension:ext];
    }
    
    // upload to CDN
    NSString *upload = _uploadAPI;
    upload = [upload stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)from.address];
    NSURL *url = [NSURL URLWithString:upload];
    [self post:(NSData *)data name:filename varName:@"file" url:url];
    
    // build download URL
    NSString *download = _downloadAPI;
    download = [download stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)from.address];
    download = [download stringByReplacingOccurrencesOfString:@"{filename}" withString:filename];
    return [NSURL URLWithString:download];
}

- (nullable NSData *)downloadEncryptedDataFromURL:(NSURL *)url {
    
    // load data with URL
    NSString *filename = [url lastPathComponent];
    NSString *path = data_filepath(filename, NO);
    if (file_exists(path)) {
        return [[NSData alloc] initWithContentsOfFile:path];
    }
    
    // download from URL
    [self get:(NSURL *)url name:filename];
    return nil;
}

- (nullable NSData *)decryptDataFromURL:(NSURL *)url
                               filename:(NSString *)name
                                wityKey:(id<MKMSymmetricKey>)key {
    // check file with local cache path
    NSString *filename1 = [url lastPathComponent];
    NSString *path1 = data_filepath(filename1, NO);
    if (!file_exists(path1)) {
        NSAssert(false, @"encrypted file not exists: %@", path1);
        return nil;
    }
    
    // decrypt it
    NSData *CT = [NSData dataWithContentsOfFile:path1];
    NSData *data = [key decrypt:CT];
    NSLog(@"decrypt file data %lu bytes -> %lu bytes", CT.length, data.length);
    
    // save the new file
    NSString *filename2 = MKMHexEncode(MKMMD5Digest(data));
    NSString *ext = [name pathExtension];
    if (ext.length > 0) {
        filename2 = [filename2 stringByAppendingPathExtension:ext];
    }
    NSAssert([filename2 isEqualToString:(id)name], @"filename error: %@, %@", filename2, name);
    NSString *path2 = data_filepath(filename2, YES);
    if ([data writeToFile:path2 atomically:YES]) {
        // erase the old file
        remove_file(path1);
    }
    return data;
}

- (BOOL)saveData:(NSData *)data filename:(NSString *)name {
    
    NSString *filename = MKMHexEncode(MKMMD5Digest(data));
    NSString *ext = [name pathExtension];
    if (ext.length > 0) {
        filename = [filename stringByAppendingPathExtension:ext];
    }
    NSAssert([filename isEqualToString:(id)name], @"filename error: %@, %@", filename, name);
    NSString *path = data_filepath(filename, YES);
    return [data writeToFile:path atomically:YES];
}

- (NSData *)loadDataWithFilename:(NSString *)name {
    
    NSString *path = data_filepath((NSString *)name, NO);
    return [NSData dataWithContentsOfFile:path];
}

-(NSString *)cachePathForFilename:(NSString *)filename{
    NSString *path = data_filepath((NSString *)filename, NO);
    return path;
}

- (BOOL)saveThumbnail:(NSData *)data filename:(NSString *)name {
    // use the same filename for thumbnail but different directory
    NSString *filename = [[NSString alloc] initWithFormat:@"%@", name];
    NSString *path = thumbnail_filepath(filename, YES);
    return [data writeToFile:path atomically:YES];
}

- (NSData *)loadThumbnailWithFilename:(NSString *)name {
    // use the same filename for thumbnail but different directory
    NSString *filename = [[NSString alloc] initWithFormat:@"%@", name];
    NSString *path = thumbnail_filepath(filename, NO);
    return [NSData dataWithContentsOfFile:path];
}

#pragma mark Avatar

- (NSURL *)uploadAvatar:(NSData *)data filename:(nullable NSString *)name sender:(id<MKMID>)ID {
    
    // upload to CDN
    NSString *upload = _uploadAPI;
    upload = [upload stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)ID.address];
    NSURL *url = [NSURL URLWithString:upload];
    [self post:(NSData *)data name:(NSString *)name varName:@"avatar" url:url];
    
    NSString *ext = [name pathExtension];
    name = MKMHexEncode(MKMMD5Digest(data));
    NSString *filename = [name stringByAppendingPathExtension:ext];
    
    // build download URL
    NSString *download = _avatarAPI;
    download = [download stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)ID.address];
    download = [download stringByReplacingOccurrencesOfString:@"{ext}" withString:ext];
    download = [download stringByReplacingOccurrencesOfString:@"{filename}" withString:filename];
    return [NSURL URLWithString:download];
}

@end
