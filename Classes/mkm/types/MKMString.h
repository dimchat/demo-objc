//
//  MKMString.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMString : NSString {
    
    NSString *_storeString; // inner string
}

- (instancetype)initWithString:(NSString *)aString;

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
