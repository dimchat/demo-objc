//
//  DIMMessageContent.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMMessageContent.h"

@interface DIMMessageContent ()

@property (nonatomic) DIMMessageType type;
@property (nonatomic) NSUInteger serialNumber;

@end

@implementation DIMMessageContent

+ (instancetype)contentWithContent:(id)content {
    if ([content isKindOfClass:[DIMMessageContent class]]) {
        return content;
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:content];
    } else if ([content isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:content];
    } else {
        NSAssert(!content, @"unexpected message content: %@", content);
        return nil;
    }
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        // randomize a serial number
        self.serialNumber = arc4random();
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // type
        NSNumber *type = [dict objectForKey:@"type"];
        _type = [type unsignedIntegerValue];
        
        // serial number
        NSNumber *sn = [dict objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
        NSAssert(_serialNumber > 0, @"sn cannot be empty");
        
        // group ID
        MKMID *ID = [dict objectForKey:@"group"];
        _group = [MKMID IDWithID:ID];
    }
    return self;
}

- (void)setType:(DIMMessageType)type {
    [_storeDictionary setObject:@(type) forKey:@"type"];
    _type = type;
}

- (void)setSerialNumber:(NSUInteger)serialNumber {
    [_storeDictionary setObject:@(serialNumber) forKey:@"sn"];
    _serialNumber = serialNumber;
}

- (void)setGroup:(MKMID *)group {
    if (![_group isEqual:group]) {
        if (group) {
            [_storeDictionary setObject:group forKey:@"group"];
        } else {
            [_storeDictionary removeObjectForKey:@"group"];
        }
        _group = group;
    }
}

#pragma mark - Text message

- (instancetype)initWithText:(const NSString *)text {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Text;
        
        // text
        [_storeDictionary setObject:text forKey:@"text"];
    }
    return self;
}

- (NSString *)text {
    return [_storeDictionary objectForKey:@"text"];
}

#pragma mark - File message

- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_File;
        
        // url or data
        NSString *url = [_delegate URLStringForFileData:data
                                               filename:name];
        if (url) {
            [_storeDictionary setObject:url forKey:@"url"];
        } else {
            NSString *str = [data base64Encode];
            [_storeDictionary setObject:str forKey:@"data"];
        }
        
        // filename
        if (name) {
            [_storeDictionary setObject:name forKey:@"filename"];
        }
    }
    return self;
}

- (NSData *)fileData {
    NSString *str = [_storeDictionary objectForKey:@"data"];
    if (str) {
        return [str base64Decode];
    }
    NSString *url = [_storeDictionary objectForKey:@"url"];
    if (url) {
        // TODO: download file from the URL
    }
    return nil;
}

- (NSString *)filename {
    return [_storeDictionary objectForKey:@"filename"];
}

#pragma mark Image message

- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DIMMessageType_Image;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)imageData {
    return [self fileData];
}

- (NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

#pragma mark Audio message

- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DIMMessageType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (NSData *)audioData {
    return [self fileData];
}

#pragma mark Video message

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DIMMessageType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)videoData {
    return [self fileData];
}

#pragma mark - Webpage message

- (instancetype)initWithURLString:(const NSString *)url
                            title:(const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Page;
        
        // url
        if (url) {
            [_storeDictionary setObject:url forKey:@"url"];
        }
        // icon
        if (icon) {
            NSString *str = [icon base64Encode];
            [_storeDictionary setObject:str forKey:@"icon"];
        }
        // title
        if (title) {
            [_storeDictionary setObject:title forKey:@"title"];
        }
        // desc
        if (desc) {
            [_storeDictionary setObject:desc forKey:@"desc"];
        }
    }
    return self;
}

- (NSString *)URLString {
    return [_storeDictionary objectForKey:@"url"];
}

- (NSString *)title {
    return [_storeDictionary objectForKey:@"title"];
}

- (NSString *)desc {
    return [_storeDictionary objectForKey:@"desc"];
}

- (NSData *)icon {
    NSString *str = [_storeDictionary objectForKey:@"icon"];
    return [str base64Decode];
}

@end

#pragma mark - Group message content

@implementation DIMMessageContent (GroupMessage)

- (instancetype)initWithText:(const NSString *)text
                       quote:(NSUInteger)sn {
    if (self = [self initWithText:text]) {
        [_storeDictionary setObject:@(sn) forKey:@"quote"];
    }
    return self;
}

- (NSUInteger)quoteNumber {
    NSNumber *sn = [_storeDictionary objectForKey:@"quote"];
    return sn.unsignedIntegerValue;
}

@end
