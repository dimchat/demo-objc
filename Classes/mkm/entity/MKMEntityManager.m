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

#import "MKMEntityManager.h"

@interface MKMEntityManager () {
    
    NSMutableDictionary<const MKMAddress *, MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMAddress *, MKMHistory *> *_historyTable;
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
    }
    return self;
}

- (MKMMeta *)metaForID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    MKMMeta *meta = [_metaTable objectForKey:ID.address];
    if (!meta && _delegate) {
        meta = [_dataSource metaForEntityID:ID];
        if ([meta matchID:ID]) {
            [_metaTable setObject:meta forKey:ID.address];
        } else {
            meta = nil;
        }
    }
    return meta;
}

- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    if ([meta matchID:ID]) {
        // set meta
        [_metaTable setObject:meta forKey:ID.address];
    }
}

- (MKMHistory *)historyForID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    MKMHistory *history = [_historyTable objectForKey:ID.address];
    if (!history && _delegate) {
        history = [_dataSource historyForEntityID:ID];
        if ([history matchID:ID]) {
            [_historyTable setObject:history forKey:ID.address];
        } else {
            history = nil;
        }
    }
    return history;
}

- (void)setHistory:(MKMHistory *)history forID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    MKMHistory *old = [_historyTable objectForKey:ID.address];
    if (history.count > old.count && [history matchID:ID]) {
        // only update longest history
        [_historyTable setObject:history forKey:ID.address];
    }
}

@end
