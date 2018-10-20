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

@implementation DIMEncryptedKeyMap

- (void) setObject:(id)anObject forKey:(const NSString *)aKey {
    NSAssert(false, @"DON'T call me");
    //[super setObject:anObject forKey:aKey];
}

- (NSData *)encryptedKeyForID:(const MKMID *)ID {
    NSString *encode = [_storeDictionary objectForKey:ID.address];
    return [encode base64Decode];
}

- (void)setEncryptedKey:(NSData *)key forID:(const MKMID *)ID {
    NSString *encode = [key base64Encode];
    [_storeDictionary setObject:encode forKey:ID.address];
}

@end

#pragma mark -

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
@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) NSData *encryptedKey;
@property (strong, nonatomic) DIMEncryptedKeyMap *encryptedKeys;

@end

@implementation DIMSecureMessage

+ (instancetype)messageWithMessage:(id)msg {
    if ([msg isKindOfClass:[DIMSecureMessage class]]) {
        return msg;
    } else if ([msg isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:msg];
    } else {
        NSAssert(!msg, @"unexpected message: %@", msg);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSData *content = nil;
    DIMEnvelope *env = nil;
    NSData *key = nil;
    self = [self initWithData:content
                     envelope:env
                 encryptedKey:key];
    return self;
}

- (instancetype)initWithData:(const NSData *)content
                    envelope:(const DIMEnvelope *)env
                encryptedKey:(const NSData *)key {
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    
    // content
    NSAssert(content, @"content cannot be empty");
    [mDict setObject:[content base64Encode] forKey:@"data"];
    
    // encrypted key
    NSAssert(key, @"key cannot be empty");
    [mDict setObject:[key base64Encode] forKey:@"key"];
    
    if (self = [super initWithDictionary:mDict]) {
        _envelope = [env copy];
        _data = [content copy];
        _encryptedKey = [key copy];
        _encryptedKeys = nil;
    }
    return self;
}

- (instancetype)initWithData:(const NSData *)content
                    envelope:(const DIMEnvelope *)env
               encryptedKeys:(const DIMEncryptedKeyMap *)keys {
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    
    // content
    NSAssert(content, @"content cannot be empty");
    [mDict setObject:[content base64Encode] forKey:@"data"];
    
    // encrypted keys
    NSAssert(keys, @"encrypted keys cannot be empty");
    [mDict setObject:keys forKey:@"keys"];
    
    if (self = [super initWithDictionary:mDict]) {
        _envelope = [env copy];
        _data = [content copy];
        _encryptedKey = nil;
        _encryptedKeys = [keys copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // sender
        id from = [dict objectForKey:@"sender"];
        from = [MKMID IDWithID:from];
        NSAssert(from, @"sender cannot be empty");
        
        // receiver
        id to = [dict objectForKey:@"receiver"];
        to = [MKMID IDWithID:to];
        NSAssert(to, @"receiver cannot be empty");
        
        // time
        id time = [dict objectForKey:@"time"];
        if (time) {
            time = number_time(time);
        }
        
        // envelope (sender, receiver, time)
        DIMEnvelope *env;
        env = [[DIMEnvelope alloc] initWithSender:from
                                         receiver:to
                                             time:time];
        _envelope = env;
        
        // content
        NSString *content = [dict objectForKey:@"data"];
        NSAssert(content, @"content data cannot be empty");
        self.data = [content base64Decode];
        
        // encrypted key
        NSString *key = [dict objectForKey:@"key"];
        if (key) {
            self.encryptedKey = [key base64Decode];
        } else {
            _encryptedKey = nil;
        }
        
        // encrypted keys
        NSDictionary *keys = [dict objectForKey:@"keys"];
        if (keys) {
            DIMEncryptedKeyMap *map;
            map = [[DIMEncryptedKeyMap alloc] initWithDictionary:keys];
            _encryptedKeys = map;
        } else {
            _encryptedKeys = nil;
        }
        
        NSAssert(key || keys, @"key or keys cannot be empty both");
    }
    
    return self;
}

@end
