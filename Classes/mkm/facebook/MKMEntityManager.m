//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

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

SingletonImplementations(MKMEntityManager, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _metaTable = [[NSMutableDictionary alloc] init];
        _historyTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Meta

- (MKMMeta *)metaForID:(const MKMID *)ID {
    MKMMeta *meta = [_metaTable objectForKey:ID.address];
    if (!meta && _dataSource) {
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
    if ([meta matchID:ID]) {
        // set meta
        [_metaTable setObject:meta forKey:ID.address];
    }
}

- (void)sendMetaForID:(const MKMID *)ID {
    MKMMeta *meta = [_metaTable objectForKey:ID.address];
    if (meta && _delegate) {
        // send out onto the network
        [_delegate entityID:ID sendMeta:meta];
    }
}

#pragma mark - History

- (MKMHistory *)historyForID:(const MKMID *)ID {
    MKMHistory *history = [_historyTable objectForKey:ID.address];
    if (!history && _dataSource) {
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
    MKMHistory *old = [_historyTable objectForKey:ID.address];
    if (history.count > old.count && [history matchID:ID]) {
        // only update longest history
        [_historyTable setObject:history forKey:ID.address];
    }
}

- (void)sendHistoryForID:(const MKMID *)ID {
    MKMHistory *history = [_historyTable objectForKey:ID.address];
    if (history && _delegate) {
        // only sendout longest history
        [_delegate entityID:ID sendHistory:history];
    }
}

- (void)sendHistoryRecord:(MKMHistoryRecord *)record
                    forID:(const MKMID *)ID {
    if (record && _delegate) {
        [_delegate entityID:ID sendHistoryRecord:record];
    }
}

@end
