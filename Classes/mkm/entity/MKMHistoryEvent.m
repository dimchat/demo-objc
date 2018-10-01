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

#import "MKMPublicKey.h"

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

+ (instancetype)operationWithOperation:(id)op {
    if ([op isKindOfClass:[MKMHistoryOperation class]]) {
        return op;
    } else if ([op isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:op];
    } else if ([op isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:op];
    } else {
        NSAssert(!op, @"unexpected operation: %@", op);
        return op;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSString *op = [dict objectForKey:@"operate"];
    NSNumber *ti = [dict objectForKey:@"time"];
    NSDate *time = date([ti unsignedIntegerValue]);
    
    if (self = [super initWithDictionary:dict]) {
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
    
    if (self = [super initWithDictionary:mDict]) {
        self.operate = op;
        self.time = time;
    }
    
    return self;
}

- (void)setExtraValue:(id)value forKey:(NSString *)key {
    NSAssert(key, @"key cannot be empty");
    NSAssert(value, @"value cannot be empty");
    
    if ([key isEqualToString:@"operate"]) {
        return;
    } else if ([key isEqualToString:@"time"]) {
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

+ (instancetype)eventWithEvent:(id)event {
    if ([event isKindOfClass:[MKMHistoryEvent class]]) {
        return event;
    } else if ([event isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:event];
    } else if ([event isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:event];
    } else {
        NSAssert(!event, @"unexpected event: %@", event);
        return event;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    id operation = [dict objectForKey:@"operation"];
    NSString *operator = [dict objectForKey:@"operator"];
    NSString *signature = [dict objectForKey:@"signature"];
    
    MKMHistoryOperation *op = nil;
    op = [MKMHistoryOperation operationWithOperation:operation];
    
    if (self = [super initWithDictionary:dict]) {
        self.operation = op;
        
        if (operator && signature) {
            NSAssert([operation isKindOfClass:[NSString class]], @"event info error: %@", dict);
            operation = [operation data];
            
            MKMID *ID = [MKMID IDWithID:operator];
            NSData *CT = [signature base64Decode];
            
            const MKMPublicKey *PK = [ID publicKey];
            BOOL OK = [PK verify:operation signature:CT];
            NSAssert(!PK || OK, @"signature error");
            
            self.operatorID = ID;
            self.signature = CT;
        }
    }
    
    return self;
}

- (instancetype)initWithOperation:(const MKMHistoryOperation *)op {
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObject:op forKey:@"operation"];
    if (self = [super initWithDictionary:dict]) {
        self.operation = op;
    }
    return self;
}

- (instancetype)initWithOperation:(const NSString *)operation
                         operator:(const MKMID *)ID
                        signature:(const NSData *)CT {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mDict setObject:operation forKey:@"operation"];
    [mDict setObject:ID forKey:@"operator"];
    [mDict setObject:[CT base64Encode] forKey:@"signature"];
    
    const MKMPublicKey *PK = [ID publicKey];
    NSData *data = [operation data];
    BOOL OK = [PK verify:data signature:CT];
    NSAssert(!PK || OK, @"signature error");
    
    MKMHistoryOperation *op;
    op = [MKMHistoryOperation operationWithOperation:operation];
    
    if (self = [super initWithDictionary:mDict]) {
        self.operation = op;
        self.operatorID = ID;
        self.signature = CT;
    }
    
    return self;
}

@end
