//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMProfile.h"
#import "MKMContact.h"

#import "MKMUser.h"

@interface MKMUser ()

@property (strong, nonatomic) const NSMutableDictionary *contacts;

@end

@implementation MKMUser

- (const NSString *)name {
    NSArray *names = [self.profile objectForKey:@"names"];
    return names.firstObject;
}

- (const MKMUserGender)gender {
    id gender = [self.profile objectForKey:@"gender"];
    if ([gender isKindOfClass:[NSString class]]) {
        if ([gender isEqualToString:@"male"]) {
            return MKMUserGenderMale;
        } else if ([gender isEqualToString:@"female"]) {
            return MKMUserGenderFemail;
        } else {
            return MKMUserGenderUnknown;
        }
    } else if ([gender isKindOfClass:[NSNumber class]]) {
        return [gender intValue];
    }
    return MKMUserGenderUnknown;
}

- (const NSString *)avatar {
    NSArray *photos = [self.profile objectForKey:@"photos"];
    return photos.firstObject;
}

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
                   history:(const MKMHistory *)history {
    if (self = [super initWithID:ID meta:meta history:history]) {
        _contacts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addContact:(const MKMContact *)contact {
    // TODO: check contact
    NSString *key = contact.ID;
    
    [_contacts setObject:contact forKey:key];
}

- (MKMContact *)getContactByID:(const MKMID *)ID {
    return [_contacts objectForKey:ID];
}

@end
