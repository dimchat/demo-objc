// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKMImmortals.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMImmortals.h"

@interface MKMImmortals () {
    
    NSMutableDictionary<NSString *, id<MKMID>>         *_idTable;
    NSMutableDictionary<id<MKMID>, id<MKMPrivateKey>> *_privateTable;
    NSMutableDictionary<id<MKMID>, id<MKMMeta>>       *_metaTable;
    NSMutableDictionary<id<MKMID>, id<MKMDocument>>   *_profileTable;
    NSMutableDictionary<id<MKMID>, DIMUser *>         *_userTable;
}

@end

@implementation MKMImmortals

- (instancetype)init {
    if (self = [super init]) {
        _idTable      = [[NSMutableDictionary alloc] initWithCapacity:2];
        _privateTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        _metaTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        _profileTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        _userTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        [self _loadBuiltInAccount:MKMIDFromString(MKM_IMMORTAL_HULK_ID)];
        [self _loadBuiltInAccount:MKMIDFromString(MKM_MONKEY_KING_ID)];
    }
    return self;
}

- (void)_loadBuiltInAccount:(id<MKMID>)ID {
    [_idTable setObject:ID forKey:[ID string]];
    NSString *filename;
    
    // load meta for ID
    filename = [ID.name stringByAppendingString:@"_meta"];
    id<MKMMeta> meta = [self _loadMeta:filename];
    [self cacheMeta:meta forID:ID];
    
    // load private key for ID
    filename = [ID.name stringByAppendingString:@"_secret"];
    id<MKMPrivateKey> key = [self _loadPrivateKey:filename];
    [self cachePrivateKey:key forID:ID];
    
    // load profile for ID
    filename = [ID.name stringByAppendingString:@"_profile"];
    id<MKMDocument> profile = [self _loadProfile:filename];
    [self cacheProfile:profile forID:ID];
}

- (nullable NSDictionary *)_loadJSONFile:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];//[NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"js"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSAssert(false, @"file not exists: %@", path);
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSAssert(data.length > 0, @"failed to load JSON file: %@", path);
    return MKMJSONDecode(MKMUTF8Decode(data));
}

- (nullable id<MKMMeta>)_loadMeta:(NSString *)filename {
    id dict = [self _loadJSONFile:filename];
    NSAssert(dict, @"failed to load meta file: %@", filename);
    return MKMMetaFromDictionary(dict);
}

- (nullable id<MKMPrivateKey>)_loadPrivateKey:(NSString *)filename {
    id dict = [self _loadJSONFile:filename];
    NSAssert(dict, @"failed to load secret file: %@", filename);
    return MKMPrivateKeyFromDictionary(dict);
}

- (nullable id<MKMDocument>)_loadProfile:(NSString *)filename {
    NSDictionary *dict = [self _loadJSONFile:filename];
    NSAssert(dict, @"failed to load profile: %@", filename);
    id<MKMDocument> profile = MKMDocumentFromDictionary(dict);
    NSAssert(profile, @"profile error: %@", dict);
    // copy 'name'
    NSString *name = [dict objectForKey:@"name"];
    if (name) {
        [profile setProperty:name forKey:@"name"];
    } else {
        NSArray<NSString *> *array = [dict objectForKey:@"names"];
        if (array.count > 0) {
            [profile setProperty:array.firstObject forKey:@"name"];
        }
    }
    // copy 'avarar'
    NSString *avarar = [dict objectForKey:@"avarar"];
    if (avarar) {
        [profile setProperty:avarar forKey:@"avarar"];
    } else {
        NSArray<NSString *> *array = [dict objectForKey:@"photos"];
        if (array.count > 0) {
            [profile setProperty:array.firstObject forKey:@"avarar"];
        }
    }
    // sign
    [self _signProfile:profile];
    return profile;
}

- (nullable NSData *)_signProfile:(id<MKMDocument>)profile {
    id<MKMID> ID = profile.ID;
    id<MKMSignKey> key = [self privateKeyForVisaSignature:ID];
    NSAssert(key, @"failed to get private key for signature: %@", ID);
    return [profile sign:key];
}

#pragma mark Cache

- (BOOL)cacheMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    NSAssert(MKMMetaMatchID(ID, meta), @"meta not match: %@, %@", ID, meta);
    [_metaTable setObject:meta forKey:ID];
    return YES;
}

- (BOOL)cachePrivateKey:(id<MKMPrivateKey>)SK forID:(id<MKMID>)ID {
    [_privateTable setObject:SK forKey:ID];
    return YES;
}

- (BOOL)cacheProfile:(id<MKMDocument>)profile forID:(id<MKMID>)ID {
    NSAssert([profile isValid], @"profile not valid: %@", profile);
    NSAssert([ID isEqual:profile.ID], @"profile not match: %@, %@", ID, profile);
    [_profileTable setObject:profile forKey:ID];
    return YES;
}

- (BOOL)cacheUser:(DIMUser *)user {
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID];
    return YES;
}

#pragma mark -

- (nullable DIMUser *)userWithID:(id<MKMID>)ID {
    DIMUser *user = [_userTable objectForKey:ID];
    if (!user) {
        if ([_idTable objectForKey:[ID string]]) {
            user = [[DIMUser alloc] initWithID:ID];
            [self cacheUser:user];
        }
    }
    return user;
}

#pragma mark - Delegates

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    return [_metaTable objectForKey:ID];
}

- (nullable id<MKMDocument>)documentForID:(id<MKMID>)ID type:(nullable NSString *)type {
    return [_profileTable objectForKey:ID];
}

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    if (![_idTable objectForKey:[user string]]) {
        return nil;
    }
    NSArray *list = [_idTable allValues];
    NSMutableArray *mArray = [list mutableCopy];
    [mArray removeObject:user];
    return mArray;
}

- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    id<MKMDocument> doc = [self documentForID:user type:MKMDocument_Visa];
    if ([doc conformsToProtocol:@protocol(MKMVisa)]) {
        id<MKMVisa> visa = (id<MKMVisa>) doc;
        if ([visa isValid]) {
            return visa.key;
        }
    }
    return nil;
}

- (id<MKMVerifyKey>)metaKeyForID:(id<MKMID>)user {
    id<MKMMeta> meta = [self metaForID:user];
    NSAssert(meta, @"failed to get meta for ID: %@", user);
    return meta.key;
}

- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(id<MKMID>)user {
    // 1. get key from visa
    id<MKMEncryptKey> visaKey = [self visaKeyForID:user];
    if (visaKey) {
        return visaKey;
    }
    // 2. get key from meta
    id metaKey = [self metaKeyForID:user];
    if ([metaKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
        return metaKey;
    }
    NSAssert(false, @"failed to get encrypt key for user: %@", user);
    return nil;
}

- (nullable NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    // 1. get key from visa
    id visaKey = [self visaKeyForID:user];
    if ([visaKey conformsToProtocol:@protocol(MKMVerifyKey)]) {
        // the sender may use communication key to sign message.data,
        // so try to verify it with visa.key here
        [mArray addObject:visaKey];
    }
    // 2. get key from meta
    id<MKMVerifyKey> metaKey = [self metaKeyForID:user];
    if (metaKey) {
        // the sender may use identity key to sign message.data,
        // try to verify it with meta.key
        [mArray addObject:metaKey];
    }
    NSAssert(mArray.count > 0, @"failed to get verify key for user: %@", user);
    return mArray;
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    id<MKMPrivateKey> key = [_privateTable objectForKey:user];
    if ([key conformsToProtocol:@protocol(MKMDecryptKey)]) {
        return @[(id<MKMDecryptKey>)key];
    }
    return nil;
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    return [_privateTable objectForKey:user];
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    return [_privateTable objectForKey:user];
}

@end
