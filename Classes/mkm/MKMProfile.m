//
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMProfile.h"

@implementation MKMProfile

- (instancetype)init {
    if (self = [super init]) {
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
