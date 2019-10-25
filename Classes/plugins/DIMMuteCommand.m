//
//  DIMMuteCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMClient/DIMClient.h>

#import "DIMMuteCommand.h"

@interface DIMMuteCommand () {
    
    NSMutableArray<DIMID *> *_list;
}

@end

@implementation DIMMuteCommand

- (instancetype)initWithList:(nullable NSArray<DIMID *> *)muteList {
    if (self = [super initWithHistoryCommand:DIMCommand_Mute]) {
        // mute-list
        if (muteList) {
            _list = [muteList mutableCopy];
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
        // create mute-list
        _list = [[NSMutableArray alloc] init];
        [_storeDictionary setObject:_list forKey:@"list"];
    } else if ([_list containsObject:ID]) {
        NSAssert(false, @"ID already exists: %@", ID);
        return;
    }
    [_list addObject:ID];
}

- (void)removeID:(DIMID *)ID {
    NSAssert(_list, @"mute-list not set yet");
    [_list removeObject:ID];
}

@end
