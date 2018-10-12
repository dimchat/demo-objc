//
//  MKMMoments.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMMeta.h"

#import "MKMMoments.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;

@end

@interface MKMMoments ()

@property (strong, nonatomic) NSArray<const MKMID *> *exclusions;
@property (strong, nonatomic) NSArray<const MKMID *> *ignores;

@end

@implementation MKMMoments

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _exclusions = [[NSMutableArray alloc] init];
        _ignores = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)copy {
    MKMMoments *moments = [super copy];
    if (moments) {
        moments.exclusions = _exclusions;
        moments.ignores = _ignores;
    }
    return moments;
}

- (MKMID *)account {
    return [self.meta buildIDWithNetworkID:MKMNetwork_Main];
}

@end

#pragma mark - Connection between Account & Moments

@implementation MKMAccount (Moments)

- (MKMID *)moments {
    return [self.meta buildIDWithNetworkID:MKMNetwork_Moments];
}

@end
