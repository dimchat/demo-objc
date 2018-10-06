//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMProfile.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@end

@implementation MKMAccount

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMProfile alloc] init];
    }
    
    return self;
}

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

@end
