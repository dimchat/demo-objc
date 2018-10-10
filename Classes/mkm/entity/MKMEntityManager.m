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

@property (strong, nonatomic) MKMHistory *history;

@end

@interface MKMEntityManager () {
    
    NSMutableDictionary<const MKMID *, MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMID *, MKMHistory *> *_historyTable;
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
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    NSAssert(ID, @"ID not found: %@", path);
    
    // meta
    meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    NSAssert(meta, @"meta not found: %@", path);
    
    // history
    history = [dict objectForKey:@"history"];
    history = [MKMHistory historyWithHistory:history];
    NSAssert(history, @"history not found: %@", path);
    
    return [self setMeta:meta history:history forID:ID];
}

- (MKMMeta *)metaWithID:(const MKMID *)ID {
    NSAssert(ID, @"ID cannot be empty");
    MKMMeta *meta = [_metaTable objectForKey:ID];
    if (!meta && _delegate) {
        meta = [_delegate queryMetaWithID:ID];
        if (meta) {
            [_metaTable setObject:meta forKey:ID];
        }
    }
    return meta;
}

- (BOOL)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID {
    if (![ID checkMeta:meta]) {
        NSAssert(false, @"ID and meta not match");
        return NO;
    }
    
    MKMMeta *oMeta = [self metaWithID:ID];
    if (oMeta) {
        // already exists
        return NO;
    }
    // set meta
    [_metaTable setObject:meta forKey:ID];
    
    return YES;
}

- (MKMHistory *)historyWithID:(const MKMID *)ID {
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

- (BOOL)addHistoryRecord:(MKMHistoryRecord *)record
                   forID:(const MKMID *)ID {
    NSAssert(record, @"record cannot be empty");
    NSAssert(ID, @"ID cannot be empty");
    
    MKMEntity *entity;
    if (ID.address.network == MKMNetwork_Main) {
        entity = [MKMAccount accountWithID:ID];
    } else if (ID.address.network == MKMNetwork_Group) {
        entity = [MKMGroup groupWithID:ID];
    }
    
    BOOL correct = [entity runHistoryRecord:record];
    if (correct) {
        MKMHistory *his = [entity history];
        NSAssert(his, @"unexpected history record: %@", record);
        // set history
        [_historyTable setObject:his forKey:ID];
    }
    return correct;
}

- (BOOL)setMeta:(MKMMeta *)meta
        history:(MKMHistory *)his
          forID:(const MKMID *)ID {
    if (![ID checkMeta:meta]) {
        NSAssert(false, @"ID and meta not match");
        return NO;
    }
    
    MKMMeta *oMeta = [self metaWithID:ID];
    if (oMeta) {
        // already exists
        return NO;
    }
    // set meta
    [_metaTable setObject:meta forKey:ID];
    
    MKMHistory *oHis = [self historyWithID:ID];
    if (oHis.count >= his.count) {
        // the longer history must be the newest
        return NO;
    }
    // set history
    [_historyTable setObject:his forKey:ID];
    
    return YES;
}

@end
