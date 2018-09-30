//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMProfile.h"
#import "MKMMemo.h"

#import "MKMContact.h"

@implementation MKMContact

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _memo = [[MKMMemo alloc] init];
    }
    
    return self;
}

- (const NSString *)name {
    NSArray *names = [_profile objectForKey:@"names"];
    return names.firstObject;
}

- (const MKMGender)gender {
    id gender = [_profile objectForKey:@"gender"];
    if ([gender isKindOfClass:[NSString class]]) {
        if ([gender isEqualToString:@"male"]) {
            return MKMGender_Male;
        } else if ([gender isEqualToString:@"female"]) {
            return MKMGender_Femail;
        } else {
            return MKMGender_Unknown;
        }
    } else if ([gender isKindOfClass:[NSNumber class]]) {
        return [gender intValue];
    }
    return MKMGender_Unknown;
}

- (const NSString *)avatar {
    NSArray *photos = [_profile objectForKey:@"photos"];
    return photos.firstObject;
}

@end
