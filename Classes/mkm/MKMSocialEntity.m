//
//  MKMSocialEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMSocialEntity.h"

@implementation MKMSocialEntity

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _members = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)checkHistoryRecord:(const MKMHistoryRecord *)record {
    // TODO: check the history to get the founder
    //       and the first owner
    return NO;
}

@end
