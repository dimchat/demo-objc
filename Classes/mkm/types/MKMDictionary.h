//
//  MKMDictionary.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMDictionary : NSDictionary {
    
    // inner dictionary
    NSMutableDictionary<const NSString *, id> *_storeDictionary;
}

- (instancetype)initWithJSONString:(const NSString *)jsonString;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
NS_DESIGNATED_INITIALIZER;

- (NSUInteger)count;
- (id)objectForKey:(const NSString *)aKey;

- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;

@end

@interface MKMDictionary (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

- (void)removeObjectForKey:(const NSString *)aKey;
- (void)setObject:(id)anObject
           forKey:(const NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
