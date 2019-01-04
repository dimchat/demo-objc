//
//  DKDSecureMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DKDEnvelope.h"
#import "DKDInstantMessage.h"

#import "DKDSecureMessage.h"

@interface DKDSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) NSData *encryptedKey;
@property (strong, nonatomic, nullable) DKDEncryptedKeyMap *encryptedKeys;

@end

@implementation DKDSecureMessage

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *data = nil;
    NSData *key = nil;
    self = [self initWithData:data encryptedKey:key envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(nullable const NSData *)key
                    envelope:(const DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        if (content) {
            _data = [content copy];
            [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        } else {
            _data = nil;
        }
        
        // encrypted key
        if (key) {
            _encryptedKey = [key copy];
            [_storeDictionary setObject:[key base64Encode] forKey:@"key"];
        } else {
            _encryptedKey = nil;
        }
        
        _encryptedKeys = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
               encryptedKeys:(nullable const DKDEncryptedKeyMap *)keys
                    envelope:(const DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        if (content) {
            _data = [content copy];
            [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        } else {
            _data = nil;
        }
        
        _encryptedKey = nil;
        
        // encrypted keys
        if (keys.count > 0) {
            _encryptedKeys = [keys copy];
            [_storeDictionary setObject:_encryptedKeys forKey:@"keys"];
        } else {
            _encryptedKeys = nil;
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _data = nil;
        _encryptedKey = nil;
        _encryptedKeys = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDSecureMessage *sMsg = [super copyWithZone:zone];
    if (sMsg) {
        sMsg.data = _data;
        sMsg.encryptedKey = _encryptedKey;
        sMsg.encryptedKeys = _encryptedKeys;
    }
    return sMsg;
}

- (NSData *)data {
    if (!_data) {
        NSString *content = [_storeDictionary objectForKey:@"data"];
        NSAssert(content, @"content data cannot be empty");
        _data = [content base64Decode];
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSString *key = [_storeDictionary objectForKey:@"key"];
        if (key) {
            _encryptedKey = [key base64Decode];
        } else {
            MKMID *ID = self.envelope.receiver;
            NSAssert(MKMNetwork_IsCommunicator(ID.type), @"receiver error");
            // get from the key map
            DKDEncryptedKeyMap *keyMap = self.encryptedKeys;
            return [keyMap encryptedKeyForID:ID];
        }
    }
    return _encryptedKey;
}

- (DKDEncryptedKeyMap *)encryptedKeys {
    if (!_encryptedKeys) {
        id keys = [_storeDictionary objectForKey:@"keys"];
        _encryptedKeys = [DKDEncryptedKeyMap mapWithMap:keys];
    }
    return _encryptedKeys;
}

@end

#pragma mark -

@implementation DKDEncryptedKeyMap

+ (instancetype)mapWithMap:(id)map {
    if ([map isKindOfClass:[DKDEncryptedKeyMap class]]) {
        return map;
    } else if ([map isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:map];
    } else {
        NSAssert(!map, @"unexpected key map: %@", map);
        return nil;
    }
}

- (void) setObject:(id)anObject forKey:(const NSString *)aKey {
    NSAssert(false, @"DON'T call me");
    //[super setObject:anObject forKey:aKey];
}

- (NSData *)encryptedKeyForID:(const MKMID *)ID {
    NSString *encode = [_storeDictionary objectForKey:ID];
    return [encode base64Decode];
}

- (void)setEncryptedKey:(NSData *)key forID:(const MKMID *)ID {
    if (key) {
        NSString *encode = [key base64Encode];
        [_storeDictionary setObject:encode forKey:ID];
    } else {
        [_storeDictionary removeObjectForKey:ID];
    }
}

@end
