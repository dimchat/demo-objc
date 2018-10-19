//
//  MKMMemo.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMMemo.h"

@interface MKMMemo ()

@property (strong, nonatomic) MKMID *ID;

@end

@implementation MKMMemo

+ (instancetype)memoWithMemo:(id)memo {
    if ([memo isKindOfClass:[MKMMemo class]]) {
        return memo;
    } else if ([memo isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:memo];
    } else if ([memo isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:memo];
    } else {
        NSAssert(!memo, @"unexpected memo: %@", memo);
        return nil;
    }
}

- (instancetype)initWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    if (self = [self init]) {
        // account ID
        if (ID.isValid) {
            _ID = [ID copy];
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        // account ID
        MKMID *ID = [dict objectForKey:@"ID"];
        ID = [MKMID IDWithID:ID];
        if (ID.isValid) {
            _ID = ID;
        }
    }
    return self;
}

- (BOOL)matchID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    return [ID isEqual:_ID];
}

@end

@implementation MKMContactMemo

@end
