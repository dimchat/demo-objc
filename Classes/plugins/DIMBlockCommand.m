//
//  DIMBlockCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMClient/DIMClient.h>

#import "DIMBlockCommand.h"

@interface DIMBlockCommand () {
    
    NSMutableArray<DIMID *> *_list;
}

@end

@implementation DIMBlockCommand

- (instancetype)initWithList:(nullable NSArray<DIMID *> *)blockList {
    if (self = [super initWithHistoryCommand:DIMCommand_Block]) {
        // block-list
        if (blockList) {
            _list = [blockList mutableCopy];
            [_storeDictionary setObject:_list forKey:@"list"];
        } else {
            _list = nil;
        }
    }
    return self;
}

- (nullable NSArray<DIMID *> *)list {
    if (!_list) {
        NSArray *array = [_storeDictionary objectForKey:@"list"];
        if (array) {
            _list = [[NSMutableArray alloc] initWithCapacity:array.count];
            DIMID *ID;
            for (NSString *item in array) {
                ID = DIMIDWithString(item);
                if ([ID isValid]) {
                    [_list addObject:ID];
                }
            }
        }
    }
    return _list;
}

- (void)addID:(DIMID *)ID {
    if (![self list]) {
        // create block-list
        _list = [[NSMutableArray alloc] init];
        [_storeDictionary setObject:_list forKey:@"list"];
    } else if ([_list containsObject:ID]) {
        NSAssert(false, @"ID already exists: %@", ID);
        return;
    }
    [_list addObject:ID];
}

- (void)removeID:(DIMID *)ID {
    NSAssert(_list, @"block-list not set yet");
    [_list removeObject:ID];
}

@end
