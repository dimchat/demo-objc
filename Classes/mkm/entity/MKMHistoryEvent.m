//
//  MKMHistoryEvent.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMEntityManager.h"

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

@property (strong, nonatomic) NSString *operate;
@property (strong, nonatomic) NSDate *time;

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
        return nil;
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
        _operate = [op copy];
        _time = [time copy];
    }
    
    return self;
}

- (void)setExtraInfo:(id)info forKey:(NSString *)key {
    NSAssert(key, @"key cannot be empty");
    NSAssert(info, @"value cannot be empty");
    
    if ([key isEqualToString:@"operate"]) {
        return;
    } else if ([key isEqualToString:@"time"]) {
        return;
    }
    
    [_storeDictionary setObject:info forKey:key];
}

- (nullable id)extraInfoForKey:(NSString *)key {
    NSAssert(key, @"key cannot be empty");
    
    return [_storeDictionary objectForKey:key];
}

@end

#pragma mark - history.events

@interface MKMHistoryEvent ()

@property (strong, nonatomic) MKMHistoryOperation *operation;

@property (strong, nonatomic) MKMID *commander;
@property (strong, nonatomic) NSData *signature;

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
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    id operation = [dict objectForKey:@"operation"];
    NSString *commander = [dict objectForKey:@"commander"];
    NSString *signature = [dict objectForKey:@"signature"];
    
    MKMHistoryOperation *op = nil;
    op = [MKMHistoryOperation operationWithOperation:operation];
    MKMID *ID = nil;
    NSData *CT = nil;
    BOOL correct = YES;
    
    // if signature isn't empty, check it with commander
    if (signature) {
        NSAssert(commander, @"commander cannot be empty");
        NSAssert([operation isKindOfClass:[NSString class]],
                 @"event info error: %@", dict);
        operation = [operation data];
        
        ID = [MKMID IDWithID:commander];
        CT = [signature base64Decode];
        
        MKMEntityManager *eman = [MKMEntityManager sharedInstance];
        MKMPublicKey *PK = [eman metaForID:ID].key;
        
        correct = [PK verify:operation signature:CT];
        NSAssert(correct, @"signature error");
    }
    
    if (self = [super initWithDictionary:dict]) {
        if (correct) {
            self.operation = op;
            self.commander = ID;
            self.signature = CT;
        } else {
            _operation = nil;
            _commander = nil;
            _signature = nil;
        }
    }
    
    return self;
}

- (instancetype)initWithOperation:(const MKMHistoryOperation *)op {
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObject:op forKey:@"operation"];
    if (self = [super initWithDictionary:dict]) {
        _operation = [op copy];
        _commander = nil;
        _signature = nil;
    }
    return self;
}

- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const MKMID *)ID
                        signature:(const NSData *)CT {
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    MKMPublicKey *PK = [eman metaForID:ID].key;
    NSData *data = [operation data];
    BOOL OK = [PK verify:data signature:CT];
    NSAssert(!PK || OK, @"signature error");
    
    MKMHistoryOperation *op;
    op = [MKMHistoryOperation operationWithOperation:operation];
    
    NSDictionary *dict = @{@"operation":operation,
                           @"commander":ID,
                           @"signature":[CT base64Encode],
                           };
    if (self = [super initWithDictionary:dict]) {
        _operation = [op copy];
        _commander = [ID copy];
        _signature = [CT copy];
    }
    
    return self;
}

@end
