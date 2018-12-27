//
//  DKDReliableMessage+Meta.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage+Meta.h"

@implementation DKDReliableMessage (Meta)

- (MKMMeta *)meta {
    id dict = [_storeDictionary objectForKey:@"meta"];
    return [MKMMeta metaWithMeta:dict];
}

- (void)setMeta:(MKMMeta *)meta {
    if (meta) {
        [_storeDictionary setObject:meta forKey:@"meta"];
    } else {
        [_storeDictionary removeObjectForKey:@"meta"];
    }
}

@end
