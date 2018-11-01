//
//  MKMProfileManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMProfile.h"
#import "MKMMemo.h"

#import "MKMProfileManager.h"

/**
 Remove 1/2 objects from the dictionary
 
 @param mDict - mutable dictionary
 */
static void reduce_table(NSMutableDictionary *mDict) {
    NSArray *keys = [mDict allKeys];
    MKMAddress *addr;
    for (NSUInteger index = 0; index < keys.count; index += 2) {
        addr = [keys objectAtIndex:index];
        [mDict removeObjectForKey:addr];
    }
}

typedef NSMutableDictionary<const MKMAddress *, MKMProfile *> MKMProfileTable;
typedef NSMutableDictionary<const MKMAddress *, MKMMemo *> MKMMemoTable;

@interface MKMProfileManager () {
    
    MKMProfileTable *_profileTable;
    MKMMemoTable *_memoTable;
}

@end

@implementation MKMProfileManager

SingletonImplementations(MKMProfileManager, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _profileTable = [[MKMProfileTable alloc] init];
        _memoTable = [[MKMMemoTable alloc] init];
    }
    return self;
}

- (void)setProfile:(MKMProfile *)profile forID:(const MKMID *)ID {
    MKMAddress *address = ID.address;
    NSAssert(address, @"address error");
    if ([profile matchID:ID]) {
        [_profileTable setObject:profile forKey:address];
    }
}

- (void)setMemo:(MKMMemo *)memo forID:(const MKMID *)ID {
    MKMAddress *address = ID.address;
    NSAssert(address, @"address error");
    if ([memo matchID:ID]) {
        [_memoTable setObject:memo forKey:address];
    }
}

- (void)reduceMemory {
    reduce_table(_profileTable);
    reduce_table(_memoTable);
}

#pragma mark MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    MKMProfile *profile = [_profileTable objectForKey:ID.address];
    if (!profile) {
        NSAssert(_dataSource, @"data source not set");
        profile = [_dataSource profileForID:ID];
        [self setProfile:profile forID:ID];
    }
    return profile;
}

- (MKMMemo *)memoForID:(const MKMID *)ID {
    MKMMemo *memo = [_memoTable objectForKey:ID.address];
    if (!memo) {
        NSAssert(_dataSource, @"data source not set");
        memo = [_dataSource memoForID:ID];
        [self setMemo:memo forID:ID];
    }
    return memo;
}

@end
