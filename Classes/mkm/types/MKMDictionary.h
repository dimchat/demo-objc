//
//  MKMDictionary.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMDictionary : NSDictionary {
    
    NSMutableDictionary *_storeDictionary; // inner dictionary
}

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;

- (NSUInteger)count;
- (id)objectForKey:(const NSString *)aKey;
- (NSEnumerator *)keyEnumerator;

@end

@interface MKMDictionary (Mutable)

- (void)removeObjectForKey:(const NSString *)aKey;
- (void)setObject:(id)anObject
           forKey:(const NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
