//
//  NSObject+JsON.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JsON)

- (NSData *)jsonData;
- (NSString *)jsonString;

@end

@interface NSString (Convert)

- (NSData *)data;

@end

@interface NSData (Convert)

- (NSString *)UTF8String;

@end

@interface NSData (JsON)

- (NSString *)jsonString;
- (NSArray *)jsonArray;
- (NSDictionary *)jsonDictionary;

- (NSMutableArray *)jsonMutableArray;
- (NSMutableDictionary *)jsonMutableDictionary;

@end

NS_ASSUME_NONNULL_END
