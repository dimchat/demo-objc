//
//  MKMSocialEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMSocialEntity.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) const MKMMeta *meta;

@end

@interface MKMSocialEntity ()

@property (strong, nonatomic) const NSString *name;

@property (strong, nonatomic) const MKMID *founder;
@property (strong, nonatomic) const MKMID *owner;

@end

@implementation MKMSocialEntity

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _members = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)isFounder:(const MKMID *)ID {
    if (_founder) {
        return [_founder isEqual:ID];
    }
    return [ID.publicKey isEqual:self.meta.key];
}

- (BOOL)isOwner:(const MKMID *)ID {
    NSAssert(_owner, @"error");
    return [_owner isEqual:ID];
}

- (void)addMember:(const MKMID *)ID {
    if ([self isMember:ID]) {
        return;
    }
    [_members addObject:ID];
}

- (void)removeMember:(const MKMID *)ID {
    if (![self isMember:ID]) {
        return;
    }
    [_members removeObject:ID];
}

- (BOOL)isMember:(const MKMID *)ID {
    return [_members containsObject:ID];
}

@end
