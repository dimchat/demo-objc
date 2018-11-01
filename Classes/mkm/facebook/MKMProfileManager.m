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

#import "MKMProfileManager.h"

@interface MKMProfileManager () {
    
    NSMutableDictionary<const MKMAddress *, MKMProfile *> *_profileTable;
}

@end

@implementation MKMProfileManager

SingletonImplementations(MKMProfileManager, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _profileTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (MKMProfile *)profileForID:(const MKMID *)ID {
    MKMProfile *profile = [_profileTable objectForKey:ID.address];
    if (!profile && _dataSource) {
        profile = [_dataSource profileForEntityID:ID];
        if ([profile matchID:ID]) {
            [_profileTable setObject:profile forKey:ID.address];
        }
    }
    return profile;
}

- (void)setProfile:(MKMProfile *)profile
             forID:(const MKMID *)ID {
    if ([profile matchID:ID]) {
        [_profileTable setObject:profile forKey:ID.address];
    }
}

- (void)sendProfileForID:(const MKMID *)ID {
    MKMProfile *profile = [_profileTable objectForKey:ID.address];
    if (profile && _delegate) {
        [_delegate entityID:ID sendProfile:profile];
    }
}

@end
