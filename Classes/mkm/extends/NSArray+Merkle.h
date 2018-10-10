//
//  NSArray+Merkle.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Merkle)

- (NSData *)merkleRoot;

@end

NS_ASSUME_NONNULL_END
