//
//  DIMFileServer.m
//  DIMClient
//
//  Created by Albert Moky on 2019/4/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMFileServer.h"

static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

/**
 Get full filepath to Documents Directory
 
 @param filename - "xxxx.png"
 @return "Library/Caches/.dim/{address}/xxxx.png"
 */
static inline NSString *full_filepath(NSString *filename) {
    // base directory: Library/Caches/.dim/{address}
    NSString *dir = caches_directory();
    dir = [dir stringByAppendingPathComponent:@".dim"];
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

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
        
        _uploadAPI = nil;   // @"http://124.156.108.150:8081/{ID}/upload"
        _downloadAPI = nil; // @"http://124.156.108.150:8081/download/{ID}/{filename}"
        
        _uploadings = [[NSMutableDictionary alloc] init];
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
    NSLog(@"progress %f", progress);
    
    // finished
    if (totalBytesSent == totalBytesExpectedToSend) {
    }
}

#pragma mark NSURLSession

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config;
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 5.0f;
        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        if (_userAgent.length > 0) {
            config.HTTPAdditionalHeaders = @{@"User-Agent": _userAgent};
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }
    return _session;
}

- (NSData *)buildHTTPBodyWithFilename:(const NSString *)name
                              varName:(const NSString *)var
                                 data:(const NSData *)data {
    
    NSMutableString *begin = [[NSMutableString alloc] init];
    [begin appendString:@"--4Tcjm5mp8BNiQN5YnxAAAnexqnbb3MrWjK\r\n"];
    [begin appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", var, name];
    [begin appendString:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    NSString *end = @"\r\n--4Tcjm5mp8BNiQN5YnxAAAnexqnbb3MrWjK--";
    
    NSUInteger len = begin.length + data.length + end.length;
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:len];
    [mData appendData:[begin data]];
    [mData appendData:[data copy]];
    [mData appendData:[end data]];
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
    [request setValue:@"multipart/form-data; boundary=4Tcjm5mp8BNiQN5YnxAAAnexqnbb3MrWjK" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    // HTTP body
    NSData *body = [self buildHTTPBodyWithFilename:filename varName:var data:data];
    
    // completion handler
    void (^handler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
    handler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"HTTP upload task complete: %@, %@, %@", response, error, [data UTF8String]);
        
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
            NSLog(@"download %@ error: %@", url, [data UTF8String]);
        } else {
            // move to caches directory
            NSFileManager *fm = [NSFileManager defaultManager];
            NSURL *path = [NSURL fileURLWithPath:full_filepath(filename)];
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

- (NSURL *)uploadEncryptedData:(const NSData *)data
                      filename:(nullable const NSString *)name
                        sender:(const DIMID *)from {
    
    // prepare filename (make sure that filenames won't conflict)
    NSString *filename = [[data md5] hexEncode];
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

- (nullable NSData *)downloadEncryptedDataFromURL:(const NSURL *)url {
    
    // load data with URL
    NSString *filename = [url lastPathComponent];
    NSString *path = full_filepath(filename);
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return [[NSData alloc] initWithContentsOfFile:path];
    }
    
    // download from URL
    [self get:(NSURL *)url name:filename];
    return nil;
}

- (nullable NSData *)decryptDataFromURL:(const NSURL *)url
                               filename:(const NSString *)name
                                wityKey:(const MKMSymmetricKey *)key {
    // check file with local cache path
    NSString *filename1 = [url lastPathComponent];
    NSString *path1 = full_filepath(filename1);
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path1]) {
        NSAssert(false, @"encrypted file not exists: %@", path1);
        return nil;
    }
    
    // decrypt it
    NSData *CT = [NSData dataWithContentsOfFile:path1];
    NSData *data = [key decrypt:CT];
    NSLog(@"decrypt file data %lu bytes -> %lu bytes", CT.length, data.length);
    
    // save the new file
    NSString *filename2 = [[data md5] hexEncode];
    NSString *ext = [name pathExtension];
    if (ext.length > 0) {
        filename2 = [filename2 stringByAppendingPathExtension:ext];
    }
    NSAssert([filename2 isEqualToString:(id)name], @"filename error: %@, %@", filename2, name);
    NSString *path2 = full_filepath(filename2);
    if ([data writeToFile:path2 atomically:YES]) {
        // erase the old file
        NSError *error = nil;
        [fm removeItemAtPath:path1 error:&error];
        NSAssert(!error, @"failed to remove old file: %@", error);
    }
    return data;
}

- (BOOL)saveData:(const NSData *)data filename:(const NSString *)name {
    
    NSString *filename = [[data md5] hexEncode];
    NSString *ext = [name pathExtension];
    if (ext.length > 0) {
        filename = [filename stringByAppendingPathExtension:ext];
    }
    NSAssert([filename isEqualToString:(id)name], @"filename error: %@, %@", filename, name);
    NSString *path = full_filepath(filename);
    return [data writeToFile:path atomically:YES];
}

- (NSData *)loadDataWithFilename:(const NSString *)name {
    
    NSString *path = full_filepath((NSString *)name);
    return [NSData dataWithContentsOfFile:path];
}

- (BOOL)saveThumbnail:(const NSData *)data filename:(const NSString *)name {
    
    NSArray *pair = [name componentsSeparatedByString:@"."];
    NSAssert(pair.count == 2, @"image filename error: %@", name);
    NSString *filename = [[NSString alloc] initWithFormat:@"%@-s.%@", pair.firstObject, pair.lastObject];
    NSString *path = full_filepath(filename);
    return [data writeToFile:path atomically:YES];
}

- (NSData *)loadThumbnailWithFilename:(const NSString *)name {
    
    NSArray *pair = [name componentsSeparatedByString:@"."];
    NSAssert(pair.count == 2, @"image filename error: %@", name);
    NSString *filename = [[NSString alloc] initWithFormat:@"%@-s.%@", pair.firstObject, pair.lastObject];
    NSString *path = full_filepath(filename);
    return [NSData dataWithContentsOfFile:path];
}

#pragma mark Avatar

- (NSURL *)uploadAvatar:(const NSData *)data filename:(const NSString *)name sender:(const MKMID *)ID {
    
    NSString *ext = [name pathExtension];
    
    // upload to CDN
    NSString *upload = _uploadAPI;
    upload = [upload stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)ID.address];
    NSURL *url = [NSURL URLWithString:upload];
    [self post:(NSData *)data name:(NSString *)name varName:@"avatar" url:url];
    
    // build download URL
    NSString *download = _avatarAPI;
    download = [download stringByReplacingOccurrencesOfString:@"{ID}" withString:(NSString *)ID.address];
    download = [download stringByReplacingOccurrencesOfString:@"{ext}" withString:ext];
    return [NSURL URLWithString:download];
}

@end
