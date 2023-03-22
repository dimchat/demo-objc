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
//  DIMHttpClient.m
//  DIMP
//
//  Created by Albert Moky on 2019/4/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"
#import "DIMUploadTask.h"
#import "DIMDownloadTask.h"

#import "DIMHttpClient.h"

static inline NSData *random_data(NSUInteger size) {
    unsigned char *buf = malloc(size * sizeof(unsigned char));
    arc4random_buf(buf, size);
    return [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
}

// hex(md5(data + secret + salt))
static inline NSData *hash_data(NSData *data, NSData *secret, NSData *salt) {
    NSUInteger len = data.length + secret.length + salt.length;
    NSMutableData *hash = [[NSMutableData alloc] initWithCapacity:len];
    [hash appendData:data];
    [hash appendData:secret];
    [hash appendData:salt];
    return MKMMD5Digest(hash);
}

static inline NSString *make_filepath(NSString *dir, NSString *filename, BOOL autoCreate) {
    if (autoCreate && ![DIMStorage createDirectoryAtPath:dir]) {
        // failed to create directory
        return nil;
    }
    return [dir stringByAppendingPathComponent:filename];
}

static inline BOOL is_hex(NSString *string) {
    static NSString *regex = @"[0-9A-Fa-f]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:string];
}
static inline BOOL is_md5(NSString *filename, NSUInteger pos) {
    if (pos != 32) {
        return NO;
    }
    if (pos < [filename length]) {
        filename = [filename substringToIndex:pos];
    }
    return is_hex(filename);
}

static inline NSString *create_filename(NSData *data, NSString *filename) {
    NSString *ext = [filename pathExtension];
    // check md5 filename
    NSUInteger pos = ext ? filename.length - ext.length - 1 : filename.length;
    if (is_md5(filename, pos)) {
        return filename;
    }
    // build md5 filename from data
    filename = MKMHexEncode(MKMMD5Digest(data));
    if (ext) {
        return [filename stringByAppendingPathExtension:ext];
    } else {
        return filename;
    }
}

// cached filename for downloaded URL:
//      hex(md5(url)) + ext
static inline NSString *filename_from_url(NSURL *url) {
    NSData *data = MKMUTF8Encode([url absoluteString]);
    NSString *filename = [url lastPathComponent];
    return create_filename(data, filename);
}

#pragma mark -

@interface DIMHttpClient () {
    
    // cache for uploaded file's URL
    NSMutableDictionary<NSString *, NSURL *> *_cdn;     // filename => URL

    // requests waiting to upload/download
    NSMutableArray<DIMUploadRequest *>   *_uploads;
    NSMutableArray<DIMDownloadRequest *> *_downloads;
    
    // tasks running
    DIMUploadTask      *_uploadingTask;
    DIMUploadRequest   *_uploadingRequest;
    DIMDownloadTask    *_downloadingTask;
    DIMDownloadRequest *_downloadingRequest;
    
    id<FSMThread> _daemon;
}

@end

@implementation DIMHttpClient

- (instancetype)init {
    if (self = [super init]) {
        _cdn       = [[NSMutableDictionary alloc] init];
        
        _uploads   = [[NSMutableArray alloc] init];
        _downloads = [[NSMutableArray alloc] init];
        
        _uploadingTask      = nil;
        _uploadingRequest   = nil;
        _downloadingTask    = nil;
        _downloadingRequest = nil;
        
        _daemon = nil;
    }
    return self;
}

- (void)start {
    [self stop];
    // start new thread
    FSMThread *thread = [[FSMThread alloc] initWithTarget:self];
    [thread start];
    _daemon = thread;
}

// Override
- (void)stop {
    [super stop];
    // wait for thread stop
    FSMThread *thread = _daemon;
    if (thread) {
        [thread cancel];
        [NSThread sleepForTimeInterval:1.0];
        _daemon = nil;
    }
}

// Override
- (BOOL)process {
    @try {
        // drive upload tasks as priority
        if ([self driveUpload] || [self driveDownload]) {
            // it's buszy
            return YES;
        } else {
            // nothing to do now, cleanup temporary files
            [self cleanup];
        }
    } @catch (NSException *exception) {
        NSLog(@"HTTP Client error: %@", exception);
    } @finally {
        
    }
    // have a rest
    return NO;
}

- (void)cleanup {
    // clean expired temporary files for upload/download
    NSAssert(false, @"override me!");
}

// private
- (BOOL)driveUpload {
    // 1. check current task
    DIMUploadTask *task = _uploadingTask;
    if (task) {
        DIMFileTransferStatus status = [task status];
        switch (status) {
            case DIMFileTransferError:
                NSLog(@"task error: %@", task);
                break;
                
            case DIMFileTransferRunning:
            case DIMFileTransferSuccess:
                // task is busy now
                return YES;
                
            case DIMFileTransferExpired:
                NSLog(@"task expired: %@", task);
                break;
                
            case DIMFileTransferFinished:
                NSLog(@"task finished: %@", task);
                break;
                
            default:
                NSAssert(status == DIMFileTransferWaiting, @"unknown status: %lu", status);
                NSLog(@"task status error: %@", task);
                break;
        }
        // remove task
        _uploadingTask = nil;
        _uploadingRequest = nil;
    }
    
    // 2. get next request
    DIMUploadRequest *req;
    @synchronized (_uploads) {
        req = [_uploads firstObject];
    }
    if (!req) {
        // nothing to upload now
        return NO;
    }
    
    // 3. check previous upload
    NSString *path = [req path];
    NSString *filename = [path lastPathComponent];
    NSURL *url;
    @synchronized (_cdn) {
        url = [_cdn objectForKey:filename];
    }
    if (url) {
        id<DIMUploadDelegate> delegate = [req delegate];
        [delegate uploadTask:req onSuccess:url];
        // uploaded previously
        return YES;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSData *secret = [req secret];
    NSData *salt = random_data(16);
    // hex(md5(data + secret + salt))
    NSData *hash = hash_data(data, secret, salt);

    // 4. build upload task
    NSString *string = [req.url absoluteString];
    // "https://sechat.dim.chat/{ID}/upload?md5={MD5}&salt={SALT}"
    id<MKMAddress> address = [req.sender address];
    string = [string stringByReplacingOccurrencesOfString:@"{ID}"
                                               withString:address.string];
    string = [string stringByReplacingOccurrencesOfString:@"{MD5}"
                                               withString:MKMHexEncode(hash)];
    string = [string stringByReplacingOccurrencesOfString:@"{SALT}"
                                               withString:MKMHexEncode(salt)];
    task = [[DIMUploadTask alloc] initWithURL:[NSURL URLWithString:string]
                                         name:req.name
                                     filename:filename
                                         data:data
                                     delegate:self];
    
    // 5. run it
    _uploadingRequest = req;
    _uploadingTask = task;
    [task run];
    return YES;
}

// private
- (BOOL)driveDownload {
    // 1. check running task
    DIMDownloadTask *task = _downloadingTask;
    if (task) {
        DIMFileTransferStatus status = [task status];
        switch (status) {
            case DIMFileTransferError:
                NSLog(@"task error: %@", task);
                break;
                
            case DIMFileTransferRunning:
            case DIMFileTransferSuccess:
                // task is busy now
                return YES;
                
            case DIMFileTransferExpired:
                NSLog(@"task expired: %@", task);
                break;
                
            case DIMFileTransferFinished:
                NSLog(@"task finished: %@", task);
                break;
                
            default:
                NSAssert(status == DIMFileTransferWaiting, @"unknown status: %lu", status);
                NSLog(@"task status error: %@", task);
                break;
        }
        // remove task
        _downloadingTask = nil;
        _downloadingRequest = nil;
    }
    
    // 2. get next request
    DIMDownloadRequest *req;
    @synchronized (_downloads) {
        req = [_downloads firstObject];
    }
    if (!req) {
        // nothing to download now
        return NO;
    }
    
    // 3. check previous download
    NSString *path = [req path];
    if ([DIMStorage fileExistsAtPath:path]) {
        id<DIMDownloadDelegate> delegate = [req delegate];
        [delegate downloadTask:req onSuccess:path];
        // download previously
        return YES;
    }
    
    // 4. build download task
    task = [[DIMDownloadTask alloc] initWithURL:req.url
                                           path:req.path
                                       delegate:req.delegate];
    
    // 5. run it
    _downloadingRequest = req;
    _downloadingTask = task;
    [task run];
    return YES;
}

// private
- (NSSet<id<DIMUploadDelegate>> *)listenersForUpload:(DIMUploadTask *)task {
    NSMutableSet<id<DIMUploadDelegate>> *listeners = [[NSMutableSet alloc] init];
    [listeners addObject:task.delegate];
    // check other requests with same filename
    NSString *filename = [task.path lastPathComponent];
    @synchronized (_uploads) {
        [_uploads enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DIMUploadRequest *req, NSUInteger idx, BOOL *stop) {
            NSString *target = [req.path lastPathComponent];
            if ([filename isEqualToString:target]) {
                [listeners addObject:req.delegate];
            }
        }];
    }
    return listeners;
}

// private
- (NSSet<id<DIMDownloadDelegate>> *)listenersForDownload:(DIMDownloadTask *)task {
    NSMutableSet<id<DIMDownloadDelegate>> *listeners = [[NSMutableSet alloc] init];
    [listeners addObject:task.delegate];
    // check other requests with same URL
    NSString *filename = filename_from_url([task url]);
    @synchronized (_downloads) {
        [_downloads enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DIMDownloadRequest *req, NSUInteger idx, BOOL *stop) {
            NSString *target = filename_from_url([req url]);
            if ([filename isEqualToString:target]) {
                [listeners addObject:req.delegate];
            }
        }];
    }
    return listeners;
}

#pragma mark DIMUploadDelegate

- (void)uploadTask:(DIMUploadTask *)task onSuccess:(NSURL *)url {
    // 1. cache upload result
    if (url) {
        [_cdn setObject:url forKey:task.filename];
    }
    NSSet<id<DIMUploadDelegate>> *listeners = [self listenersForUpload:task];
    // 2. callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMUploadDelegate> delegate, BOOL *stop) {
        [delegate uploadTask:task onSuccess:url];
    }];
}

- (void)uploadTask:(DIMUploadTask *)task onFailed:(NSException *)error {
    NSSet<id<DIMUploadDelegate>> *listeners = [self listenersForUpload:task];
    // callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMUploadDelegate> delegate, BOOL *stop) {
        [delegate uploadTask:task onFailed:error];
    }];
}

- (void)uploadTask:(DIMUploadTask *)task onError:(NSError *)error {
    NSSet<id<DIMUploadDelegate>> *listeners = [self listenersForUpload:task];
    // callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMUploadDelegate> delegate, BOOL *stop) {
        [delegate uploadTask:task onError:error];
    }];
}

#pragma mark DIMDownloadDelegate

- (void)downloadTask:(DIMDownloadTask *)task onSuccess:(NSString *)path {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    // callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task onSuccess:path];
    }];
}

- (void)downloadTask:(DIMDownloadTask *)task onFailed:(NSException *)error {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    // callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task onFailed:error];
    }];
}

- (void)downloadTask:(DIMDownloadTask *)task onError:(NSError *)error {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    // callback
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task onError:error];
    }];
}

@end

#pragma mark -

@implementation DIMHttpClient (Common)

- (nullable NSURL *)upload:(NSURL *)api
                    secret:(NSData *)key
                      data:(NSData *)data
                      path:(NSString *)path
                      name:(const NSString *)var
                    sender:(id<MKMID>)from
                  delegate:(id<DIMUploadDelegate>)delegate {
    // 1. check previous upload
    NSString *filename = [path lastPathComponent];
    NSURL *url;
    @synchronized (_cdn) {
        // filename in format: hex(md5(data)) + ext
        url = [_cdn objectForKey:filename];
    }
    if (url) {
        // already uploaded
        return url;
    }
    NSString *dir = [path stringByDeletingLastPathComponent];
    
    // 2. save file data to the local path
    if (!make_filepath(dir, filename, YES)) {
        NSAssert(false, @"failed to create directory: %@", dir);
        return nil;
    }
    if (![data writeToFile:path atomically:YES]) {
        NSAssert(false, @"failed to save binary: %@", path);
        return nil;
    }
    
    // 3. build request
    DIMUploadRequest *req;
    req = [[DIMUploadRequest alloc] initWithURL:api
                                           path:path
                                         secret:key
                                           name:var
                                         sender:from
                                       delegate:delegate];
    @synchronized (_uploads) {
        [_uploads addObject:req];
    }
    return nil;
}

- (nullable NSString *)download:(NSURL *)url
                           path:(NSString *)path
                       delegate:(id<DIMDownloadDelegate>)delegate {
    // 1. check previous download
    if ([DIMStorage fileExistsAtPath:path]) {
        // already downloaded
        return path;
    }
    
    // 2. build request
    DIMDownloadRequest *req;
    req = [[DIMDownloadRequest alloc] initWithURL:url
                                             path:path
                                         delegate:delegate];
    @synchronized (_downloads) {
        [_downloads addObject:req];
    }
    return nil;
}

@end
