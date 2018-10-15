//
//  MKMSocialEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMEntityManager.h"

#import "MKMSocialEntity.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;

@end

@interface MKMSocialEntity ()

@property (strong, nonatomic) MKMID *founder;
@property (strong, nonatomic) MKMID *owner;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSArray<const MKMID *> *members;

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

- (id)copy {
    MKMSocialEntity *social = [super copy];
    if (social) {
        social.founder = _founder;
        social.owner = _owner;
        social.name = _name;
        
        social.members = _members;
    }
    return social;
}

- (BOOL)isFounder:(const MKMID *)ID {
    if (_founder) {
        return [_founder isEqual:ID];
    }
    // founder not set yet, check by meta
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    MKMMeta *meta = [eman metaForID:ID];
    // the key in social entity's meta
    // must be the same (public) key of founder
    return [meta.key isEqual:self.meta.key];
}

- (BOOL)isOwner:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    NSAssert(_owner, @"owner not set yet");
    return [_owner isEqual:ID];
}

- (void)addMember:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    if ([self isMember:ID]) {
        // don't add same member twice
        return;
    }
    [_members addObject:ID];
}

- (void)removeMember:(const MKMID *)ID {
    NSAssert([self isMember:ID], @"no such member found");
    [_members removeObject:ID];
}

- (BOOL)isMember:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    return [_members containsObject:ID];
}

@end
