//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistory.h"
#import "MKMEntityDelegate.h"

#import "MKMEntityManager.h"

@interface MKMEntityManager () {
    
    NSMutableDictionary<const MKMID *, MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMID *, MKMHistory *> *_historyTable;
}

@end

@implementation MKMEntityManager

static MKMEntityManager *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _metaTable = [[NSMutableDictionary alloc] init];
        _historyTable = [[NSMutableDictionary alloc] init];
#if DEBUG
        // Immortals
        [self _loadEntityInfoFromFile:@"mkm_hulk"];
        [self _loadEntityInfoFromFile:@"mkm_moki"];
#endif
    }
    return self;
}

// inner function
- (BOOL)_loadEntityInfoFromFile:(NSString *)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    NSDictionary *dict;
    MKMID *ID;
    MKMMeta *meta;
    MKMHistory *history;
    
    path = [bundle pathForResource:filename ofType:@"plist"];
    if (![fm fileExistsAtPath:path]) {
        NSAssert(false, @"cannot load: %@", path);
        return NO;
    }
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    NSAssert(ID.isValid, @"invalid ID: %@", path);
    
    // meta
    meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    NSAssert([meta matchID:ID], @"meta not match: %@", path);
    
    // history
    history = [dict objectForKey:@"history"];
    history = [MKMHistory historyWithHistory:history];
    NSAssert(history, @"history not found: %@", path);
    
    [self setMeta:meta forID:ID];
    [self setHistory:history forID:ID];
    
    // private key
    NSDictionary *skd = [dict objectForKey:@"privateKey"];
    MKMPrivateKey *SK = [MKMPrivateKey keyWithKey:skd];
    [SK saveKeyWithIdentifier:ID.address];
    
    return ID.isValid && [meta matchID:ID] && history;
}

- (MKMMeta *)metaForID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    MKMMeta *meta = [_metaTable objectForKey:ID];
    if (!meta && _delegate) {
        meta = [_delegate queryMetaWithID:ID];
        if (meta) {
            [_metaTable setObject:meta forKey:ID];
        }
    }
    return meta;
}

- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    if ([meta matchID:ID]) {
        // set meta
        [_metaTable setObject:meta forKey:ID];
    }
}

- (MKMHistory *)historyForID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    MKMHistory *history = [_historyTable objectForKey:ID];
    if (!history && _delegate) {
        history = [_delegate queryHistoryWithID:ID];
        if (history) {
            [_historyTable setObject:history forKey:ID];
        }
    }
    return history;
}

- (void)setHistory:(MKMHistory *)history forID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    if (history) {
        [_historyTable setObject:history forKey:ID];
    }
}

@end
