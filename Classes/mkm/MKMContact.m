//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMProfile.h"

#import "MKMContact.h"

@implementation MKMContact

- (const NSString *)name {
    NSArray *names = [self.profile objectForKey:@"names"];
    return names.firstObject;
}

- (const NSString *)avatar {
    NSArray *photos = [self.profile objectForKey:@"photos"];
    return photos.firstObject;
}

@end
