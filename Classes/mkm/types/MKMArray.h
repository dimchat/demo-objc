//
//  MKMArray.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMArray : NSArray {
    
    NSMutableArray *_storeArray; // inner array
}

- (instancetype)initWithJSONString:(const NSString *)jsonString;

- (instancetype)initWithArray:(NSArray *)array
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                          count:(NSUInteger)cnt
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
NS_DESIGNATED_INITIALIZER;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;

@end

@interface MKMArray (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject
             atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index
                  withObject:(id)anObject;

@end

NS_ASSUME_NONNULL_END
