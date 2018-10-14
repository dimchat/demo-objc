//
//  DIMSecureMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMEnvelope.h"
#import "DIMInstantMessage.h"

#import "DIMSecureMessage.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

//static NSNumber *time_number(const NSDate *time) {
//    if (!time) {
//        time = now();
//    }
//    NSTimeInterval ti = [time timeIntervalSince1970];
//    return [NSNumber numberWithDouble:ti];
//}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMSecureMessage ()

@property (strong, nonatomic) DIMEnvelope *envelope;
@property (strong, nonatomic) NSData *content;

@property (strong, nonatomic) NSData *encryptedKey;
@property (strong, nonatomic) NSDictionary *encryptedKeys;

@end

@implementation DIMSecureMessage

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSData *content = nil;
    DIMEnvelope *env = nil;
    NSData *key = nil;
    self = [self initWithContent:content
                        envelope:env
                    encryptedKey:key];
    return self;
}

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                   encryptedKey:(const NSData *)key {
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    
    // content
    NSAssert(content, @"content cannot be empty");
    [mDict setObject:[content base64Encode] forKey:@"content"];
    
    // encrypted key
    NSAssert(key, @"key cannot be empty");
    [mDict setObject:[key base64Encode] forKey:@"key"];
    
    if (self = [super initWithDictionary:mDict]) {
        _envelope = [env copy];
        _content = [content copy];
        _encryptedKey = [key copy];
    }
    return self;
}

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                  encryptedKeys:(const NSDictionary *)keys {
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    
    // content
    NSAssert(content, @"content cannot be empty");
    [mDict setObject:[content base64Encode] forKey:@"content"];
    
    // encrypted keys
    NSAssert(keys, @"encrypted keys cannot be empty");
    [mDict setObject:keys forKey:@"keys"];
    
    if (self = [super initWithDictionary:mDict]) {
        _envelope = [env copy];
        _content = [content copy];
        _encryptedKeys = [keys copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // sender
        id from = [dict objectForKey:@"sender"];
        if (from) {
            from = [MKMID IDWithID:from];
        }
        // receiver
        id to = [dict objectForKey:@"receiver"];
        if (to) {
            to = [MKMID IDWithID:to];
        }
        // time
        id time = [dict objectForKey:@"time"];
        if (time) {
            time = number_time(time);
        }
        
        DIMEnvelope *env;
        env = [[DIMEnvelope alloc] initWithSender:from
                                         receiver:to
                                             time:time];
        self.envelope = env;
        
        // content
        NSString *content = [dict objectForKey:@"content"];
        NSAssert(content, @"content cannot be empty");
        self.content = [content base64Decode];
        
        // encrypted key
        NSString *key = [dict objectForKey:@"key"];
        self.encryptedKey = [key base64Decode];
        
        // encrypted keys
        NSDictionary *keys = [dict objectForKey:@"keys"];
        self.encryptedKeys = keys;
    }
    
    return self;
}

@end
