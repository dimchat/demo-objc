//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistory.h"

#import "MKMEntityManager.h"

@interface MKMEntityManager () {
    
    NSMutableDictionary *_metaMap;
    NSMutableDictionary *_historyMap;
}

@end

@implementation MKMEntityManager

static MKMEntityManager *_sharedManager = nil;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        _sharedManager = [[self alloc] init];
    }
    return _sharedManager;
}

+ (instancetype)alloc {
    NSAssert(!_sharedManager, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _metaMap = [[NSMutableDictionary alloc] init];
        _historyMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (MKMMeta *)metaWithID:(const MKMID *)ID {
    MKMMeta *meta = [_metaMap objectForKey:ID];
    if (!meta && _delegate) {
        meta = [_delegate queryMetaWithID:ID];
        if (meta) {
            [_metaMap setObject:meta forKey:ID];
        }
    }
    return meta;
}

- (MKMHistory *)historyWithID:(const MKMID *)ID {
    MKMHistory *history = [_historyMap objectForKey:ID];
    if (!history && _delegate) {
        history = [_delegate updateHistoryWithID:ID];
        if (history) {
            [_historyMap setObject:history forKey:ID];
        }
    }
    return history;
}

@end
