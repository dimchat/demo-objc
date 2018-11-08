//
//  MKMHistoryTransaction.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMID.h"

#import "MKMHistoryOperation.h"

#import "MKMHistoryTransaction.h"

typedef NSMutableDictionary<const MKMAddress *, NSString *> MKMConfirmTableM;

@interface MKMHistoryTransaction ()

@property (strong, nonatomic) MKMHistoryOperation *operation;

@property (strong, nonatomic) MKMID *commander;
@property (strong, nonatomic) NSData *signature;

@property (strong, nonatomic) MKMConfirmTableM *confirmations;

@end

@implementation MKMHistoryTransaction

+ (instancetype)transactionWithTransaction:(id)event {
    if ([event isKindOfClass:[MKMHistoryTransaction class]]) {
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
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _operation = nil;
        _commander = nil;
        _signature = nil;
        _confirmations = nil;
    }
    
    return self;
}

- (instancetype)initWithOperation:(const MKMHistoryOperation *)op {
    NSDictionary *dict = @{@"operation":op};
    if (self = [super initWithDictionary:dict]) {
        _operation = [op copy];
        _commander = nil;
        _signature = nil;
        _confirmations = nil;
    }
    return self;
}

- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const MKMID *)ID
                        signature:(const NSData *)CT {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"ID error");
    NSAssert(CT, @"signature cannot be empty");
    NSDictionary *dict = @{@"operation":operation,
                           @"commander":ID,
                           @"signature":[CT base64Encode],
                           };
    if (self = [super initWithDictionary:dict]) {
        _operation = [MKMHistoryOperation operationWithOperation:operation];
        _commander = [ID copy];
        _signature = [CT copy];
        _confirmations = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMHistoryTransaction *event = [super copyWithZone:zone];
    if (event) {
        event.operation = _operation;
        event.commander = _commander;
        event.signature = _signature;
        event.confirmations = _confirmations;
    }
    return event;
}

- (MKMHistoryOperation *)operation {
    if (!_operation) {
        id op = [_storeDictionary objectForKey:@"operation"];
        _operation = [MKMHistoryOperation operationWithOperation:op];
    }
    return _operation;
}

- (MKMID *)commander {
    if (!_commander) {
        id ID = [_storeDictionary objectForKey:@"commander"];
        _commander = [MKMID IDWithID:ID];
    }
    return _commander;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        if (CT) {
            _signature = [CT base64Decode];
        }
    }
    return _signature;
}

- (MKMConfirmTable *)confirmations {
    if (!_confirmations) {
        _confirmations = [_storeDictionary objectForKey:@"confirmations"];
    }
    return _confirmations;
}

- (void)setConfirmation:(const NSData *)CT forID:(const MKMID *)ID {
    if (!_confirmations) {
        MKMConfirmTableM *table;
        table = [_storeDictionary objectForKey:@"confirmations"];
        if (!table) {
            table = [[MKMConfirmTableM alloc] init];
            [_storeDictionary setObject:table forKey:@"confirmations"];
        }
        _confirmations = table;
    }
    NSString *signature = [CT base64Encode];
    [_confirmations setObject:signature forKey:ID.address];
}

- (NSData *)confirmationForID:(const MKMID *)ID {
    NSString *signature = [self.confirmations objectForKey:ID.address];
    NSAssert(signature, @"confirmation not found for %@", ID);
    return [signature base64Decode];
}

@end

@implementation MKMHistoryTransaction (Link)

- (NSData *)previousSignature {
    return _operation.previousSignature;
}

@end
