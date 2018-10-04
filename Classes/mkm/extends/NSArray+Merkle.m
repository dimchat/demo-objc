//
//  NSArray+Merkle.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/5.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "NSArray+Merkle.h"

static NSData *merge_data(const NSData *data1, const NSData *data2) {
    assert(data1);
    assert(data2);
    NSData *left = [data1 copy];
    NSData *right = [data2 copy];
    NSUInteger len = [left length] + [right length];
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:len];
    [mData appendData:left];
    [mData appendData:right];
    return mData;
}

@implementation NSArray (Merkle)

- (NSData *)merkleRoot {
    NSUInteger count = [self count];
    if (count == 0) {
        return nil;
    }
    
    // 1. get all leaves with SHA256
    NSMutableArray *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:count];
    NSData *data;
    for (id item in self) {
        if ([item isKindOfClass:[NSString class]]) {
            data = [item data];
        } else {
            NSAssert([item isKindOfClass:[NSData class]], @"error item: %@", item);
            data = item;
        }
        [mArray addObject:[data sha256]];
    }
    
    NSData *data1, *data2;
    NSUInteger pos;
    while (count > 1) {
        // 2. if the array contains a single node in the end,
        //    duplicate it.
        if (count % 2 == 1) {
            [mArray addObject:[mArray lastObject]];
            ++count;
        }
        
        // 3. calculate this level
        for (pos = 0; (pos+1) < count; pos += 2) {
            data1 = [mArray objectAtIndex:pos];
            data2 = [mArray objectAtIndex:(pos+1)];
            // data = sha256(data1 + data2)
            data = merge_data(data1, data2);
            data = [data sha256];
            [mArray replaceObjectAtIndex:(pos/2) withObject:data];
        }
        
        // 4. cut the array
        count /= 2;
        [mArray removeObjectsInRange:NSMakeRange(count, count)];
    }
    
    return [mArray firstObject];
}

@end
