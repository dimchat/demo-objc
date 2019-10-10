//
//  DIMClientTests.m
//  DIMClientTests
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DIMClient/DIMClient.h>

@interface DIMClientTests : XCTestCase

@end

@implementation DIMClientTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testPassword {
    
    NSString *string = @"Hello world!";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    DIMSymmetricKey *key1 = DIMPasswordFromString(@"12345");
    NSData *ct = [key1 encrypt:data];
    
    DIMSymmetricKey *key2 = DIMPasswordFromString(@"12345");
    NSData *pt = [key2 decrypt:ct];
    
    NSAssert([key1 isEqual:key2], @"keys not equal: %@, %@", key1, key2);
    
    NSLog(@"key1: %@", key1);
    NSLog(@"key2: %@", key2);
    
    NSString *base64 = [ct base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *res = [NSString stringWithCString:[pt bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"%@ -> %@ -> %@", string, base64, res);
}

@end
