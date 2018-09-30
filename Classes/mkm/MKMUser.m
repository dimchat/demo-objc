//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMProfile.h"
#import "MKMContact.h"

#import "MKMUser.h"

@implementation MKMUser

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _contacts = [[NSMutableDictionary alloc] init];
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

- (BOOL)addContact:(const MKMContact *)contact {
    if (contact.ID.isValid == NO) {
        // ID error
        return NO;
    }
    if (contact.status != MKMAccountStatusRegistered) {
        // status error
        return NO;
    }
    
    [_contacts setObject:contact forKey:contact.ID];
    return YES;
}

- (MKMContact *)getContactByID:(const MKMID *)ID {
    return [_contacts objectForKey:ID];
}

@end
