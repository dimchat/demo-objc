//
//  MKMFacebook.m
//  iChat
//
//  Created by Albert Moky on 2018/10/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMProfile.h"
#import "MKMProfileDelegate.h"

#import "MKMFacebook.h"

@interface MKMFacebook () {
    
    NSMutableDictionary<const MKMID *, MKMProfile *> *_profileTable;
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
        
        // Immortals
        [self loadProfileFromFile:@"mkm_hulk"];
        [self loadProfileFromFile:@"mkm_moki"];
    }
    return self;
}

- (BOOL)loadProfileFromFile:(NSString *)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    NSDictionary *dict;
    MKMID *ID;
    
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
    
    // load profile
    MKMProfile *profile;
    profile = [dict objectForKey:@"profile"];
    if (!profile) {
        NSAssert(false, @"profile not found: %@", path);
        return NO;
    }
    profile = [MKMProfile profileWithProfile:profile];
    [self setProfile:profile forID:ID];
    
    return profile;
}

- (MKMProfile *)profileWithID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    MKMProfile *profile = [_profileTable objectForKey:ID];
    if (!profile && _delegate) {
        profile = [_delegate queryProfileWithID:ID];
        if (profile) {
            [_profileTable setObject:profile forKey:ID];
        }
    }
    return profile;
}

- (BOOL)setProfile:(MKMProfile *)profile
             forID:(const MKMID *)ID {
    NSAssert(profile, @"profile cannot be empty");
    NSAssert([ID isValid], @"Invalid ID");
    
    if ([profile matchID:ID]) {
        [_profileTable setObject:profile forKey:ID];
        return YES;
    } else {
        NSAssert(false, @"profile signature error");
        return NO;
    }
}

@end
