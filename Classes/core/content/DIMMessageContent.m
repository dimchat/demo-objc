//
//  DIMMessageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

static inline NSUInteger serial_number(void) {
    // because we must make sure all messages in a same chat box won't have
    // same serial numbers, so we can't use time-related numbers, therefore
    // the best choice is a totally random number, maybe.
    return arc4random();
//    // last serial number
//    static NSUInteger serialNumber = 0;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSDate *now = [[NSDate alloc] init];
//        serialNumber = [now timeIntervalSince1970] - 1;
//    });
//    // get new serial number with current timestamp
//    NSDate *now = [[NSDate alloc] init];
//    NSUInteger timestamp = [now timeIntervalSince1970];
//    if (serialNumber < timestamp) {
//        serialNumber = timestamp;
//    } else {
//        ++serialNumber;
//    }
//    return serialNumber;
}

@interface DIMMessageContent () {
    
    DIMMessageType _type;
    NSUInteger _serialNumber;
    
    MKMID *_group;
    __weak id<DIMMessageContentDelegate> _delegate;
}

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

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [self initWithType:DIMMessageType_Unknown];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _type = DIMMessageType_Unknown;
        _serialNumber = 0;
        _group = nil;
        
        _delegate = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DIMMessageType)type {
    NSUInteger sn = serial_number();
    NSDictionary *dict = @{@"type":@(type),
                           @"sn"  :@(sn),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _serialNumber = sn;
        _group = nil;
        
        _delegate = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMMessageContent *content = [super copyWithZone:zone];
    if (content) {
        //content.type = _type;
        //content.serialNumber = _serialNumber;
        //content.group = _group;
        content.delegate = _delegate;
    }
    return content;
}

- (DIMMessageType)type {
    if (_type == DIMMessageType_Unknown) {
        NSNumber *type = [_storeDictionary objectForKey:@"type"];
        _type = [type unsignedIntegerValue];
    }
    return _type;
}

- (void)setType:(DIMMessageType)type {
    [_storeDictionary setObject:@(type) forKey:@"type"];
    _type = type;
}

- (NSUInteger)serialNumber {
    if (_serialNumber == 0) {
        NSNumber *sn = [_storeDictionary objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
        NSAssert(_serialNumber > 0, @"sn cannot be empty");
    }
    return _serialNumber;
}

- (void)setSerialNumber:(NSUInteger)serialNumber {
    NSAssert(serialNumber != 0, @"serian number error");
    [_storeDictionary setObject:@(serialNumber) forKey:@"sn"];
    _serialNumber = serialNumber;
}

- (MKMID *)group {
    if (!_group) {
        MKMID *ID = [_storeDictionary objectForKey:@"group"];
        _group = [MKMID IDWithID:ID];
    }
    return _group;
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

@end
