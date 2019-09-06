//
//  DIMStorage.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMStorage : NSObject

@property (readonly, strong, nonatomic) NSString *documentDirectory;
@property (readonly, strong, nonatomic) NSString *cachesDirectory;

- (BOOL)createDirectoryAtPath:(NSString *)directory;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (BOOL)removeItemAtPath:(NSString *)path;

- (nullable NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path;
- (BOOL)dictionary:(NSDictionary *)dict writeToBinaryFile:(NSString *)path;

- (nullable NSArray *)arrayWithContentsOfFile:(NSString *)path;
- (BOOL)array:(NSArray *)list writeToFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
