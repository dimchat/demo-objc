//
//  DIMSecureMessage.m
//  DIMCore
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

@interface DIMSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) NSData *encryptedKey;
@property (strong, nonatomic) DIMEncryptedKeyMap *encryptedKeys;

@end

@implementation DIMSecureMessage

- (instancetype)initWithEnvelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *data = nil;
    NSData *key = nil;
    self = [self initWithData:data encryptedKey:key envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(const NSData *)key
                    envelope:(const DIMEnvelope *)env {
    if (self = [super initWithEnvelope:env]) {
        // content data
        _data = [content copy];
        [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        
        // encrypted key
        _encryptedKey = [key copy];
        [_storeDictionary setObject:[key base64Encode] forKey:@"key"];
        
        _encryptedKeys = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                    envelope:(const DIMEnvelope *)env {
    if (self = [super initWithEnvelope:env]) {
        // content data
        _data = [content copy];
        [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        
        // encrypted keys
        _encryptedKeys = [keys copy];
        [_storeDictionary setObject:keys forKey:@"keys"];
        
        _encryptedKey = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
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
