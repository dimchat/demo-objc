//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMHistory.h"
#import "MKMEntity.h"
#import "MKMEntity+History.h"
#import "MKMAccount.h"
#import "MKMGroup.h"

#import "MKMEntityDelegate.h"
#import "MKMAccountHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"

#import "MKMEntityManager.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) const MKMHistory *history;

@end

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
    NSAssert(ID, @"ID cannot be empty");
    MKMMeta *meta = [_metaMap objectForKey:ID];
    if (!meta && _delegate) {
        meta = [_delegate queryMetaWithID:ID];
        if (meta) {
            [_metaMap setObject:meta forKey:ID];
        }
    }
    return meta;
}

- (BOOL)setMeta:(const MKMMeta *)meta forID:(const MKMID *)ID {
    NSAssert(meta, @"meta cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    BOOL correct = [ID checkMeta:meta];
    if (correct) {
        [_metaMap setObject:meta forKey:ID];
        [_delegate postMeta:meta forID:ID];
    }
    return correct;
}

- (MKMHistory *)historyWithID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    MKMHistory *history = [_historyMap objectForKey:ID];
    if (!history && _delegate) {
        history = [_delegate queryHistoryWithID:ID];
        if (history) {
            [_historyMap setObject:history forKey:ID];
        }
    }
    return history;
}

- (NSUInteger)setHistory:(const MKMHistory *)history forID:(const MKMID *)ID {
    NSAssert(history, @"history cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    MKMMeta *meta = [self metaWithID:ID];
    NSAssert(meta, @"meta not found: %@", ID);
    
    MKMEntity *entity;
    MKMEntityHistoryDelegate *delegate;
    if (ID.address.network == MKMNetwork_Main) {
        delegate = [[MKMAccountHistoryDelegate alloc] init];
        entity = [[MKMAccount alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    } else if (ID.address.network == MKMNetwork_Group) {
        delegate = [[MKMGroupHistoryDelegate alloc] init];
        entity = [[MKMGroup alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    }
    
    NSUInteger count = [entity runHistory:history];
    if (count > 0) {
        const MKMHistory *his = [entity history];
        NSAssert(his, @"error");
        [_historyMap setObject:his forKey:ID];
        
        [_delegate postHistory:history forID:ID];
    }
    return count;
}

- (BOOL)addHistoryRecord:(const MKMHistoryRecord *)record forID:(const MKMID *)ID {
    NSAssert(record, @"record cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    MKMMeta *meta = [self metaWithID:ID];
    NSAssert(meta, @"meta not found: %@", ID);
    
    MKMEntity *entity;
    MKMEntityHistoryDelegate *delegate;
    if (ID.address.network == MKMNetwork_Main) {
        delegate = [[MKMAccountHistoryDelegate alloc] init];
        entity = [[MKMAccount alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    } else if (ID.address.network == MKMNetwork_Group) {
        delegate = [[MKMGroupHistoryDelegate alloc] init];
        entity = [[MKMGroup alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    }
    
    BOOL correct = [entity runHistoryRecord:record];
    if (correct) {
        const MKMHistory *his = [entity history];
        NSAssert(his, @"error");
        [_historyMap setObject:his forKey:ID];
        
        [_delegate postHistoryRecord:record forID:ID];
    }
    return correct;
}

- (BOOL)setMeta:(const MKMMeta *)meta
        history:(const MKMHistory *)history
          forID:(const MKMID *)ID {
    NSAssert(meta, @"meta cannot be empty");
    NSAssert(history, @"history cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    BOOL correct = [ID checkMeta:meta];
    if (correct) {
        [_metaMap setObject:meta forKey:ID];
    }
    
    MKMEntity *entity;
    MKMEntityHistoryDelegate *delegate;
    if (ID.address.network == MKMNetwork_Main) {
        delegate = [[MKMAccountHistoryDelegate alloc] init];
        entity = [[MKMAccount alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    } else if (ID.address.network == MKMNetwork_Group) {
        delegate = [[MKMGroupHistoryDelegate alloc] init];
        entity = [[MKMGroup alloc] initWithID:ID meta:meta];
        entity.historyDelegate = delegate;
    }
    
    NSUInteger count = [entity runHistory:history];
    if (count > 0) {
        const MKMHistory *his = [entity history];
        NSAssert(his, @"error");
        [_historyMap setObject:his forKey:ID];
    }
    
    if (correct && count > 0) {
        [_delegate postMeta:meta history:history forID:ID];
        return YES;
    }
    return NO;
}

@end