//
//  NSArray+Merkle.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "NSArray+Merkle.h"

static inline NSData *merge_data(NSData *data1, NSData *data2) {
    assert(data1);
    assert(data2);
    NSUInteger len = [data1 length] + [data2 length];
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:len];
    [mData appendData:data1];
    [mData appendData:data2];
    return mData;
}

@implementation NSArray (Merkle)

- (NSData *)merkleRoot {
    NSUInteger count = [self count];
    if (count == 0) {
        return nil;
    }
    
    // 1. get all leaves with SHA256D
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
        [mArray addObject:[data sha256d]];
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
            data = [data sha256d];
            [mArray replaceObjectAtIndex:(pos/2) withObject:data];
        }
        
        // 4. cut the array
        count /= 2;
        [mArray removeObjectsInRange:NSMakeRange(count, count)];
    }
    
    return [mArray firstObject];
}

@end
