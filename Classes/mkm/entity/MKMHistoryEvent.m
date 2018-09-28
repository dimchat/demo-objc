//
//  MKMHistoryEvent.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMID.h"

#import "MKMHistoryEvent.h"

static NSDate * now(void) {
    return [NSDate date];
}

static NSTimeInterval timestamp(const NSDate *time) {
    return [time timeIntervalSince1970];
}

static NSDate *date(NSTimeInterval time) {
    return [NSDate dateWithTimeIntervalSince1970:time];
}

#pragma mark - history.events.operation

@interface MKMHistoryOperation ()

@property (strong, nonatomic) const NSString *operate;
@property (strong, nonatomic) const NSDate *time;

@end

@implementation MKMHistoryOperation

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithOperationInfo:dict];
    return self;
}

- (instancetype)initWithOperationInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    NSString *op = [dict objectForKey:@"operate"];
    NSNumber *ti = [dict objectForKey:@"time"];
    NSDate *time = date([ti unsignedIntegerValue]);
    
    if (self = [self initWithDictionary:dict]) {
        self.operate = op;
        self.time = time;
    }
    
    return self;
}

- (instancetype)initWithOperate:(const NSString *)op {
    NSDate *time = now();
    self = [self initWithOperate:op time:time];
    return self;
}

- (instancetype)initWithOperate:(const NSString *)op
                           time:(const NSDate *)time {
    NSNumber *number = [NSNumber numberWithUnsignedInteger:timestamp(time)];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [mDict setObject:op forKey:@"operate"];
    [mDict setObject:number forKey:@"time"];
    
    if (self = [self initWithDictionary:mDict]) {
        self.operate = op;
        self.time = time;
    }
    
    return self;
}

- (id)copy {
    return [[MKMHistoryOperation alloc] initWithDictionary:self];
}

- (id)mutableCopy {
    return [self copy];
}

- (void)setExtraValue:(id)value forKey:(NSString *)key {
    NSAssert([value isKindOfClass:[NSString class]], @"value must be string");
    
    if ([key isEqualToString:@"operate"]) {
        return;
    }
    if ([key isEqualToString:@"time"]) {
        return;
    }
    [_storeDictionary setObject:value forKey:key];
}

@end

#pragma mark - history.events

@interface MKMHistoryEvent ()

@property (strong, nonatomic) const MKMHistoryOperation *operation;

@property (strong, nonatomic) const MKMID *operatorID;
@property (strong, nonatomic) const NSData *signature;

@end

@implementation MKMHistoryEvent

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithEventInfo:dict];
    return self;
}

- (instancetype)initWithEventInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    if (self = [self initWithDictionary:dict]) {
        NSString *operator = [dict objectForKey:@"operator"];
        NSString *signature = [dict objectForKey:@"signature"];
        id operation = [dict objectForKey:@"operation"];
        MKMHistoryOperation *op = nil;
        
        if (operator && signature) {
            NSAssert([operation isKindOfClass:[NSString class]], @"event info error: %@", info);
            op = [[MKMHistoryOperation alloc] initWithJSONString:operation];
            
            MKMID *ID = [[MKMID alloc] initWithString:operator];
            NSData *CT = [signature base64Decode];
            self.operatorID = ID;
            self.signature = CT;
        } else {
            NSAssert([operation isKindOfClass:[NSDictionary class]], @"event info error: %@", info);
            op = [[MKMHistoryOperation alloc] initWithOperationInfo:operation];
        }
        self.operation = op;
    }
    
    return self;
}

- (instancetype)initWithOperation:(const MKMHistoryOperation *)op {
    MKMID *ID = nil;
    NSData *CT = nil;
    self = [self initWithOperation:op operator:ID signature:CT];
    return self;
}

- (instancetype)initWithOperation:(const MKMHistoryOperation *)op
                         operator:(const MKMID *)ID
                        signature:(const NSData *)CT {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (ID && CT) {
        NSString *str = [op jsonString];
        [mDict setObject:str forKey:@"operation"];
        [mDict setObject:ID forKey:@"operator"];
        [mDict setObject:[CT base64Encode] forKey:@"signature"];
    } else {
        [mDict setObject:op forKey:@"operation"];
    }
    
    if (self = [self initWithDictionary:mDict]) {
        self.operation = op;
        self.operatorID = ID;
        self.signature = CT;
    }
    
    return self;
}

- (id)copy {
    return [[MKMHistoryEvent alloc] initWithOperation:_operation operator:_operatorID signature:_signature];
}

@end
