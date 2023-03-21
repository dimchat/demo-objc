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

#import "DIMHttpClient.h"

@interface UploadReq : NSObject

@property(nonatomic, strong) NSString *path;      // temporary path

//@property(nonatomic, strong) NSData *data;        // encrypted file data
@property(nonatomic, strong) NSString *filename;  // filename
@property(nonatomic, strong) id<MKMID> sender;    // message sender
@property(nonatomic, weak) id<DIMUploadDelegate> delegate;

@property(nonatomic, strong) const NSString *name;      // form var
@end

@implementation UploadReq

@end

@interface DownloadReq : NSObject

@property(nonatomic, strong) NSString *path;      // cache path

@property(nonatomic, strong) NSURL *url;          // remote URL
@property(nonatomic, weak) id<DIMDownloadDelegate> delegate;

@end

@implementation DownloadReq

@end

static inline NSData *random_data(NSUInteger size) {
    unsigned char *buf = malloc(size * sizeof(unsigned char));
    arc4random_buf(buf, size);
    return [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
}

// hex(md5(data + secret + salt))
static inline NSString *hash_data(NSData *data, NSData *secret, NSData *salt) {
    NSUInteger len = data.length + secret.length + salt.length;
    NSMutableData *hash = [[NSMutableData alloc] initWithCapacity:len];
    [hash appendData:data];
    [hash appendData:secret];
    [hash appendData:salt];
    return MKMHexEncode(MKMMD5Digest(hash));
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

// temporary filename for uploading data:
//      hex(md5(data)) + ext
static inline NSString *filename_from_data(NSData *data, NSString *filename) {
    return create_filename(data, filename);
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
    // cache for downloaded file's path
    NSMutableDictionary<NSURL *, NSString *> *_caches;  // URL => local path

    // requests waiting to upload/download
    NSMutableArray<UploadReq *> *_uploads;
    NSMutableArray<DownloadReq *> *_downloads;
    
    // tasks running
    DIMUploadTask *_uploading;
    DIMDownloadTask *_downloading;
}

@property(nonatomic, retain) id<FSMThread> daemon;

@property(nonatomic, strong) NSString *avatarDirectory;
@property(nonatomic, strong) NSString *cachesDirectory;

@property(nonatomic, strong) NSString *uploadDirectory;
@property(nonatomic, strong) NSString *downloadDirectory;

@end

@implementation DIMHttpClient

OKSingletonImplementations(DIMHttpClient, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _cdn         = [[NSMutableDictionary alloc] init];
        _caches      = [[NSMutableDictionary alloc] init];
        
        _uploads     = [[NSMutableArray alloc] init];
        _downloads   = [[NSMutableArray alloc] init];
        
        _uploading   = nil;
        _downloading = nil;
        
        self.daemon = nil;
        
        self.avatarDirectory   = nil;
        self.cachesDirectory   = nil;
        self.uploadDirectory   = nil;
        self.downloadDirectory = nil;
    }
    return self;
}

- (NSString *)avatarDirectory {
    if (!_avatarDirectory) {
        NSString *dir = [DIMStorage cachesDirectory];
        dir = [dir stringByAppendingPathComponent:@".mkm"];
        dir = [dir stringByAppendingPathComponent:@"avatar"];
        _avatarDirectory = dir;
    }
    return _avatarDirectory;
}

- (NSString *)cachesDirectory {
    if (!_cachesDirectory) {
        NSString *dir = [DIMStorage cachesDirectory];
        dir = [dir stringByAppendingPathComponent:@".dkd"];
        dir = [dir stringByAppendingPathComponent:@"caches"];
        _cachesDirectory = dir;
    }
    return _cachesDirectory;
}

- (NSString *)uploadDirectory {
    if (!_uploadDirectory) {
        NSString *dir = [DIMStorage cachesDirectory];
        dir = [dir stringByAppendingPathComponent:@".dkd"];
        dir = [dir stringByAppendingPathComponent:@"upload"];
        _uploadDirectory = dir;
    }
    return _uploadDirectory;
}

- (NSString *)downloadDirectory {
    if (!_downloadDirectory) {
        NSString *dir = [DIMStorage cachesDirectory];
        dir = [dir stringByAppendingPathComponent:@".dkd"];
        dir = [dir stringByAppendingPathComponent:@"download"];
        _downloadDirectory = dir;
    }
    return _downloadDirectory;
}

- (void)start {
    FSMThread *thread = [self daemon];
    if (!thread) {
        thread = [[FSMThread alloc] initWithTarget:self];
        [thread start];
    }
}

// Override
- (BOOL)process {
    @try {
        BOOL ok1 = [self driveUpload];
        BOOL ok2 = [self driveDownload];
        return ok1 || ok2;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    // have a rest
    return NO;
}

// private
- (BOOL)driveUpload {
    // 1. check current task
    DIMUploadTask *task = _uploading;
    if (task) {
        DIMFileTransferStatus status = [task status];
        if (status == DIMFileTransferRunning || status == DIMFileTransferSuccess) {
            // current task is still running (or calling delegate
            return YES;
        }
        NSAssert(status != DIMFileTransferWaiting, @"status error: %ld", status);
        _uploads = nil;
    }
    
    // 2. get next request
    UploadReq *req;
    @synchronized (_uploads) {
        req = [_uploads firstObject];
    }
    if (!req) {
        // nothing to upload now
        return NO;
    }
    
    // 3. load data
    NSString *path = [req path];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];

    NSData *secret = [self uploadSecret];
    NSData *salt = random_data(16);
    // hex(md5(data + secret + salt))
    NSString *hash = hash_data(data, secret, salt);

    id<MKMID> ID = [req sender];
    
    // 4. build upload task
    NSString *url = [self uploadAPI];
    url = [url stringByReplacingOccurrencesOfString:@"{ID}" withString:[ID.address string]];
    url = [url stringByReplacingOccurrencesOfString:@"{MD5}" withString:hash];
    url = [url stringByReplacingOccurrencesOfString:@"{SALT}" withString:MKMHexEncode(salt)];
    
    task = [[DIMUploadTask alloc] initWithURL:[NSURL URLWithString:url]
                                         path:req.path
                                         name:req.name
                                     delegate:req.delegate];
    _uploading = task;
    
    // 5. run it
    [task run];
    return YES;
}

// private
- (BOOL)driveDownload {
    return NO;
}

// private
- (NSSet<id<DIMUploadDelegate>> *)listenersForUpload:(DIMUploadTask *)task {
    NSMutableSet<id<DIMUploadDelegate>> *listeners = [[NSMutableSet alloc] init];
    [listeners addObject:task.delegate];
    // check other requests with same filename
    NSString *filename = [task.path lastPathComponent];
    @synchronized (_uploads) {
        [_uploads enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(UploadReq *req, NSUInteger idx, BOOL *stop) {
            if ([filename isEqualToString:req.filename]) {
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
    NSURL *url = task.url;
    @synchronized (_downloads) {
        [_downloads enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DownloadReq *req, NSUInteger idx, BOOL *stop) {
            if ([url isEqual:req.url]) {
                [listeners addObject:req.delegate];
            }
        }];
    }
    return listeners;
}

#pragma mark DIMUploadDelegate

- (void)uploadTask:(DIMUploadTask *)task successWithResponse:(NSData *)html {
    NSSet<id<DIMUploadDelegate>> *listeners = [self listenersForUpload:task];
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMUploadDelegate> delegate, BOOL *stop) {
        [delegate uploadTask:task successWithResponse:html];
    }];
}

- (void)uploadTask:(DIMUploadTask *)task failedWithError:(NSError *)error {
    NSSet<id<DIMUploadDelegate>> *listeners = [self listenersForUpload:task];
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMUploadDelegate> delegate, BOOL *stop) {
        [delegate uploadTask:task failedWithError:error];
    }];
}

#pragma mark DIMDownloadDelegate

- (void)downloadTask:(DIMDownloadTask *)task successWithPath:(NSString *)filepath {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task successWithPath:filepath];
    }];
}

- (void)downloadTask:(DIMDownloadTask *)task failedWithError:(NSError *)error {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task failedWithError:error];
    }];
}

- (void)downloadTask:(DIMDownloadTask *)task errorWithResponse:(NSData *)html {
    NSSet<id<DIMDownloadDelegate>> *listeners = [self listenersForDownload:task];
    [listeners enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(id<DIMDownloadDelegate> delegate, BOOL *stop) {
        [delegate downloadTask:task errorWithResponse:html];
    }];
}

@end

#pragma mark -

@implementation DIMHttpClient (Common)

- (nullable NSURL *)uploadFileData:(NSData *)data
                     fromDirectory:(NSString *)dir
                      withFilename:(NSString *)filename
                              name:(const NSString *)var
                            sender:(id<MKMID>)from
                          delegate:(id<DIMUploadDelegate>)delegate {
    // 1. check previous upload
    @synchronized (_cdn) {
        NSURL *url = [_cdn objectForKey:filename];
        if (url) {
            // already uploaded
            return url;
        }
    }
    // 2. save file data to the local path
    NSString *path = make_filepath(dir, filename, YES);
    [data writeToFile:path atomically:YES];
    // 3. build request
    UploadReq *req = [[UploadReq alloc] init];
    req.path = path;
    req.filename = filename;
    req.sender = from;
    req.delegate = delegate;
    req.name = var;
    // 4. add task
    @synchronized (_uploads) {
        [_uploads addObject:req];
    }
    return nil;
}

- (nullable NSData *)downloadFileDataFromURL:(NSURL *)url
                                 toDirectory:(NSString *)dir
                                withFilename:(NSString *)filename
                                    delegate:(id<DIMDownloadDelegate>)delegate {
    NSString *path = make_filepath(dir, filename, NO);
    // 1. check previous download
    if ([DIMStorage fileExistsAtPath:path]) {
        // already downloaded before
        return [[NSData alloc] initWithContentsOfFile:path];
    }
    // 2. build request
    DownloadReq *req = [[DownloadReq alloc] init];
    req.url = url;
    req.path = path;
    req.delegate = delegate;
    // 3. add task
    @synchronized (_downloads) {
        [_downloads addObject:req];
    }
    return nil;
}

@end

static const NSString *FORM_AVATAR = @"avatar";
static const NSString *FORM_FILE   = @"file";

@implementation DIMHttpClient (EncryptedData)

- (nullable NSURL *)uploadEncryptedData:(NSData *)data
                               filename:(NSString *)filename
                                 sender:(id<MKMID>)from
                               delegate:(id<DIMUploadDelegate>)delegate {
    // save data to the temporary directory, and then upload it from there;
    // after upload task success, the temporary file should be removed.
    filename = filename_from_data(data, filename);
    NSString *dir = [self uploadDirectory];
    return [self uploadFileData:data fromDirectory:dir withFilename:filename
                           name:FORM_FILE sender:from delegate:delegate];
}

- (nullable NSData *)downloadEncryptedDataFromURL:(NSURL *)url
                                         delegate:(id<DIMDownloadDelegate>)delegate {
    // download to the temporary directory, the delegate should decrypt it
    // and move to caches directory
    NSString *filename = filename_from_url(url);
    NSString *dir = [self downloadDirectory];
    return [self downloadFileDataFromURL:url toDirectory:dir
                            withFilename:filename delegate:delegate];
}

@end

@implementation DIMHttpClient (Avatar)

- (nullable NSURL *)uploadAvatar:(NSData *)image
                        filename:(NSString *)filename
                          sender:(id<MKMID>)from
                        delegate:(id<DIMUploadDelegate>)delegate {
    // save data to the avatar directory, and then upload it from there.
    filename = filename_from_data(image, filename);
    NSString *dir = [self avatarDirectory];
    return [self uploadFileData:image fromDirectory:dir withFilename:filename
                           name:FORM_AVATAR sender:from delegate:delegate];
}

- (nullable NSData *)downloadAvatarFromURL:(NSURL *)url
                                  delegate:(id<DIMDownloadDelegate>)delegate {
    // download to the avatar directory directly
    NSString *filename = filename_from_url(url);
    NSString *dir = [self avatarDirectory];
    return [self downloadFileDataFromURL:url toDirectory:dir
                            withFilename:filename delegate:delegate];
}

@end
