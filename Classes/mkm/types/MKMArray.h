//
//  MKMArray.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMArray : NSArray {
    
    NSMutableArray *_storeArray; // inner array
}

- (instancetype)init;
- (instancetype)initWithArray:(NSArray *)array;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (NSEnumerator *)objectEnumerator;

@end

@interface MKMArray (Mutable)

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject
             atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index
                  withObject:(id)anObject;

@end

NS_ASSUME_NONNULL_END
