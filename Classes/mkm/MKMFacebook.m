//
//  MKMFacebook.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMProfile.h"
#import "MKMProfileDelegate.h"

#import "MKMFacebook.h"

@interface MKMFacebook () {
    
    NSMutableDictionary<const MKMAddress *, MKMProfile *> *_profileTable;
}

@end

@implementation MKMFacebook

static MKMFacebook *s_sharedInstance = nil;

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
        _profileTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (MKMProfile *)profileWithID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    MKMProfile *profile = [_profileTable objectForKey:ID.address];
    if (!profile && _delegate) {
        profile = [_delegate queryProfileWithID:ID];
        if ([profile matchID:ID]) {
            [_profileTable setObject:profile forKey:ID.address];
        }
    }
    return profile;
}

- (void)setProfile:(MKMProfile *)profile
             forID:(const MKMID *)ID {
    NSAssert(profile, @"profile cannot be empty");
    NSAssert([ID isValid], @"Invalid ID");
    if ([profile matchID:ID]) {
        [_profileTable setObject:profile forKey:ID.address];
    }
}

@end
