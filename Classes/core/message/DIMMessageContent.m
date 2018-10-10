//
//  DIMMessageContent.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

#import "DIMMessageContent.h"

@interface DIMMessageContent ()

@property (nonatomic) DIMMessageType type;
@property (nonatomic) NSUInteger serialNumber;

@property (strong, nonatomic) MKMID *group;
@property (nonatomic) NSUInteger quoteNumber;

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
        return content;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        // randomize a serial number
        self.serialNumber = arc4random();
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // type
        NSNumber *type = [dict objectForKey:@"type"];
        _type = [type unsignedIntegerValue];
        // serial number
        NSNumber *sn = [dict objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
        
        // group ID
        MKMID *ID = [dict objectForKey:@"group"];
        if (ID) {
            ID = [MKMID IDWithID:ID];
            _group = [ID copy];
        }
        // quote
        NSNumber *quote = [dict objectForKey:@"quote"];
        _quoteNumber = [quote unsignedIntegerValue];
    }
    return self;
}

- (instancetype)initWithText:(const NSString *)text {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Text;
        
        // text
        [_storeDictionary setObject:text forKey:@"text"];
    }
    return self;
}

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

- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DIMMessageType_Image;
        
        // TODO: snapshot
    }
    return self;
}

- (instancetype)initWithAudioData:(const NSData *)data {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DIMMessageType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DIMMessageType_Video;
        
        // TODO: snapshot
    }
    return self;
}

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

- (void)setType:(DIMMessageType)type {
    [_storeDictionary setObject:@(type) forKey:@"type"];
    _type = type;
}

- (void)setSerialNumber:(NSUInteger)serialNumber {
    [_storeDictionary setObject:@(serialNumber) forKey:@"sn"];
    _serialNumber = serialNumber;
}

#pragma mark Group message content

- (void)setGroup:(MKMID *)group {
    if (![_group isEqual:group]) {
        if (group) {
            [_storeDictionary setObject:group forKey:@"group"];
        } else {
            [_storeDictionary removeObjectForKey:@"group"];
        }
        _group = [group copy];
    }
}

- (void)setQuoteNumber:(NSUInteger)quoteNumber {
    if (quoteNumber == 0) {
        [_storeDictionary removeObjectForKey:@"quote"];
    } else {
        [_storeDictionary setObject:@(quoteNumber) forKey:@"quote"];
    }
    _quoteNumber = quoteNumber;
}

@end

#pragma mark - Group message content

@implementation DIMMessageContent (GroupMessage)

- (instancetype)initWithText:(const NSString *)text
                       quote:(NSUInteger)sn {
    if (self = [self initWithText:text]) {
        self.quoteNumber = sn;
    }
    return self;
}

@end
