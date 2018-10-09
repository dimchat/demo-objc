//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMProfile.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccount

- (instancetype)init {
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    self = [self initWithID:ID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (!ID) {
        ID = [MKMID IDWithID:MKM_MONKEY_KING_ID];
        NSAssert(!meta, @"unexpected meta: %@", meta);
    }
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMProfile alloc] init];
    }
    return self;
}

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

- (void)setProfile:(NSString *)string forKey:(const NSString *)key {
    NSAssert(string, @"profile value cannot be empty");
    
    if ([key isEqualToString:@"name"]) {
        NSMutableArray *names = [_profile objectForKey:@"names"];
        if ([names isKindOfClass:[NSMutableArray class]]) {
            // add directly
            [names addObject:string];
        } else if ([names isKindOfClass:[NSArray class]]) {
            // make mutable and add
            names = [names mutableCopy];
            [names addObject:string];
            [_profile setObject:names forKey:@"names"];
        } else {
            // make new array
            names = [[NSMutableArray alloc] init];
            [names addObject:string];
            [_profile setObject:names forKey:@"names"];
        }
    } else if ([key isEqualToString:@"photo"]) {
        NSMutableArray *photos = [_profile objectForKey:@"photos"];
        if ([photos isKindOfClass:[NSMutableArray class]]) {
            // add directly
            [photos addObject:string];
        } else if ([photos isKindOfClass:[NSArray class]]) {
            // make mutable and add
            photos = [photos mutableCopy];
            [photos addObject:string];
            [_profile setObject:photos forKey:@"photos"];
        } else {
            // make new array
            photos = [[NSMutableArray alloc] init];
            [photos addObject:string];
            [_profile setObject:photos forKey:@"photos"];
        }
    } else {
        [_profile setObject:string forKey:key];
    }
}

- (NSString *)profileForKey:(const NSString *)key {
    return [_profile objectForKey:key];
}

- (const NSString *)name {
    NSArray *names = [_profile objectForKey:@"names"];
    return names.firstObject;
}

- (MKMGender)gender {
    NSString *gender = [self profileForKey:@"gender"];
    if ([gender isEqualToString:MKMMale]) {
        return MKMGender_Male;
    } else if ([gender isEqualToString:MKMFemale]) {
        return MKMGender_Femail;
    }
    return MKMGender_Unknown;
}

- (const NSString *)avatar {
    NSArray *photos = [_profile objectForKey:@"photos"];
    return photos.firstObject;
}

@end
