//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
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
    
    NSMutableDictionary<const MKMID *, const MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMID *, const MKMHistory *> *_historyTable;
}

@end

@implementation MKMEntityManager

static MKMEntityManager *s_sharedManager = nil;

+ (instancetype)sharedManager {
    if (!s_sharedManager) {
        s_sharedManager = [[self alloc] init];
    }
    return s_sharedManager;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedManager, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _metaTable = [[NSMutableDictionary alloc] init];
        _historyTable = [[NSMutableDictionary alloc] init];
        
        // Immortals
        [self loadEntityInfoFromFile:@"mkm_hulk"];
        [self loadEntityInfoFromFile:@"mkm_moki"];
    }
    return self;
}

- (BOOL)loadEntityInfoFromFile:(NSString *)filename {
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
    
    // ID
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    ID = [dict objectForKey:@"ID"];
    if (!ID) {
        NSAssert(false, @"ID not found: %@", path);
        return NO;
    }
    ID = [MKMID IDWithID:ID];
    
    // load meta
    meta = [dict objectForKey:@"meta"];
    if (!meta) {
        NSAssert(false, @"meta not found: %@", path);
        return NO;
    }
    meta = [MKMMeta metaWithMeta:meta];
    [self setMeta:meta forID:ID];
    
    // load history
    history = [dict objectForKey:@"history"];
    if (!history) {
        NSAssert(false, @"history not found: %@", path);
        return NO;
    }
    history = [MKMHistory historyWithHistory:history];
    [self setHistory:history forID:ID];
    
    return YES;
}

- (const MKMMeta *)metaWithID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    const MKMMeta *meta = [_metaTable objectForKey:ID];
    if (!meta && _delegate) {
        meta = [_delegate queryMetaWithID:ID];
        if (meta) {
            [_metaTable setObject:meta forKey:ID];
        }
    }
    return meta;
}

- (BOOL)setMeta:(const MKMMeta *)meta forID:(const MKMID *)ID {
    NSAssert(meta, @"meta cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    BOOL correct = [ID checkMeta:meta];
    if (correct) {
        [_metaTable setObject:meta forKey:ID];
        [_delegate postMeta:meta forID:ID];
    }
    return correct;
}

- (const MKMHistory *)historyWithID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    const MKMHistory *history = [_historyTable objectForKey:ID];
    if (!history && _delegate) {
        history = [_delegate queryHistoryWithID:ID];
        if (history) {
            [_historyTable setObject:history forKey:ID];
        }
    }
    return history;
}

- (NSUInteger)setHistory:(const MKMHistory *)history forID:(const MKMID *)ID {
    NSAssert(history, @"history cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    const MKMMeta *meta = [self metaWithID:ID];
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
        [_historyTable setObject:his forKey:ID];
        
        [_delegate postHistory:history forID:ID];
    }
    return count;
}

- (BOOL)addHistoryRecord:(const MKMHistoryRecord *)record forID:(const MKMID *)ID {
    NSAssert(record, @"record cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    const MKMMeta *meta = [self metaWithID:ID];
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
        [_historyTable setObject:his forKey:ID];
        
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
        [_metaTable setObject:meta forKey:ID];
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
        [_historyTable setObject:his forKey:ID];
    }
    
    if (correct && count > 0) {
        [_delegate postMeta:meta history:history forID:ID];
        return YES;
    }
    return NO;
}

@end
