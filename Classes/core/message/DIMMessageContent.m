//
//  DIMMessageContent.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

@interface DIMMessageContent () {
    
    DIMMessageType _type;
}

// random number to identify message content
@property (nonatomic) NSUInteger serialNumber;

// GroupID for group message
@property (strong, nonatomic) const MKMID *group;
// SerialNumber for referenced reply in group chatting
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
        // TODO: randomize a serial number
        _serialNumber = 0;
        [_storeDictionary setObject:@(_serialNumber) forKey:@"sn"];
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
            self.group = [MKMID IDWithID:ID];
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
        _type = DIMMessageType_Text;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
        // text
        [_storeDictionary setObject:text forKey:@"text"];
    }
    return self;
}

- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name {
    if (self = [self init]) {
        // type
        _type = DIMMessageType_File;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
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
        _type = DIMMessageType_Image;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
        // snapshot
    }
    return self;
}

- (instancetype)initWithAudioData:(const NSData *)data {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        _type = DIMMessageType_Audio;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
        // Automatic Speech Recognition
    }
    return self;
}

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        _type = DIMMessageType_Video;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
        // snapshot
    }
    return self;
}

- (instancetype)initWithURLString:(const NSString *)url
                            title:(const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon {
    if (self = [self init]) {
        // type
        _type = DIMMessageType_Page;
        [_storeDictionary setObject:@(_type) forKey:@"type"];
        
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

@end

#pragma mark - Group message content

@implementation DIMMessageContent (GroupMessage)

- (instancetype)initWithText:(const NSString *)text
                       quote:(NSUInteger)sn {
    if (self = [self initWithText:text]) {
        _quoteNumber = sn;
    }
    return self;
}

- (void)setGroup:(const MKMID *)group {
    if (![_group isEqual:group]) {
        if (group) {
            [_storeDictionary setObject:group forKey:@"group"];
        } else {
            [_storeDictionary removeObjectForKey:@"group"];
        }
        _group = [group copy];
    }
}

@end
