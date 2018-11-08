//
//  MKMHistoryBlock.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"
#import "NSArray+Merkle.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistoryTransaction.h"

#import "MKMBarrack.h"

#import "MKMHistoryBlock.h"

static NSMutableArray *json_array(const NSArray *events) {
    NSMutableArray *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[events count]];
    
    NSString *string;
    for (id item in events) {
        if ([item isKindOfClass:[NSString class]]) {
            string = item;
        } else {
            string = [item jsonString];
        }
        [mArray addObject:string];
    }
    
    return mArray;
}

@interface MKMHistoryBlock ()

@property (strong, nonatomic) NSMutableArray *transactions;
@property (strong, nonatomic) NSData *merkleRoot;
@property (strong, nonatomic) NSData *signature;
@property (strong, nonatomic) MKMID *recorder;

@end

@implementation MKMHistoryBlock

+ (instancetype)blockWithBlock:(id)record {
    if ([record isKindOfClass:[MKMHistoryBlock class]]) {
        return record;
    } else if ([record isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:record];
    } else if ([record isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:record];
    } else {
        NSAssert(!record, @"unexpected record: %@", record);
        return nil;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        // lazy
        _transactions = nil;
        _merkleRoot = nil;
        _signature = nil;
        _recorder = nil;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _transactions = nil;
        _merkleRoot = nil;
        _signature = nil;
        _recorder = nil;
    }
    return self;
}

- (instancetype)initWithTransactions:(const NSArray *)events
                              merkle:(const NSData *)hash
                           signature:(const NSData *)CT
                            recorder:(nullable const MKMID *)ID {
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    // events
    NSMutableArray *mArray;
    NSAssert(events.count > 0, @"events error");
    if (hash && CT) {
        mArray = json_array(events);
    } else {
        mArray = [events mutableCopy];
    }
    [mDict setObject:mArray forKey:@"events"];
    
    // merkle
    if (hash) {
        NSAssert(CT, @"error");
        [mDict setObject:[hash base64Encode] forKey:@"merkle"];
    }
    
    // signature
    if (CT) {
        NSAssert(hash, @"error");
        [mDict setObject:[CT base64Encode] forKey:@"signature"];
    }
    
    // recorder
    if (ID) {
        NSAssert(!hash || CT, @"error");
        [mDict setObject:ID forKey:@"recorder"];
    }
    
    if (self = [super initWithDictionary:mDict]) {
        _transactions = mArray;
        _merkleRoot = [hash copy];
        _signature = [CT copy];
        _recorder = [ID copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMHistoryBlock *record = [super copyWithZone:zone];
    if (record) {
        record.transactions = _transactions;
        record.merkleRoot = _merkleRoot;
        record.signature = _signature;
        record.recorder = _recorder;
    }
    return record;
}

- (NSArray *)transactions {
    if (!_transactions) {
        NSMutableArray *mArray = [_storeDictionary objectForKey:@"events"];
        if (!mArray) {
            mArray = [[NSMutableArray alloc] init];
            [_storeDictionary setObject:mArray forKey:@"events"];
        }
        _transactions = mArray;
    }
    return _transactions;
}

- (NSData *)merkleRoot {
    if (!_merkleRoot) {
        NSString *hash = [_storeDictionary objectForKey:@"merkle"];
        if (hash) {
            _merkleRoot = [hash base64Decode];
        } else {
            // calculate merkle root for events
            NSArray *array = json_array(self.transactions);
            _merkleRoot = [array merkleRoot];
            [_storeDictionary setObject:[_merkleRoot base64Encode] forKey:@"merkle"];
        }
    }
    return _merkleRoot;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        if (CT) {
            _signature = [CT base64Decode];
        } else {
            NSAssert(false, @"signature not set yet");
        }
    }
    return _signature;
}

- (MKMID *)recorder {
    if (!_recorder) {
        MKMID *ID = [_storeDictionary objectForKey:@"recorder"];
        _recorder = [MKMID IDWithID:ID];
    }
    return _recorder;
}

- (void)addTransaction:(const MKMHistoryTransaction *)event {
    if (![self.transactions containsObject:event]) {
        [_transactions addObject:event];
    }
    
    // clear for refresh
    [_storeDictionary removeObjectForKey:@"merkle"];
    [_storeDictionary removeObjectForKey:@"signature"];
    _merkleRoot = nil;
    _signature = nil;
}

- (BOOL)signWithPrivateKey:(const MKMPrivateKey *)SK {
    MKMPublicKey *PK = MKMPublicKeyForID(self.recorder);
    if ([PK isMatch:SK]) {
        self.signature = [SK sign:self.merkleRoot];
        return _signature != nil;
    } else {
        NSAssert(false, @"only recorder's private key allows here");
        return NO;
    }
}

@end

@implementation MKMHistoryBlock (Link)

- (NSData *)previousSignature {
    NSData *prevSign = nil;
    MKMHistoryTransaction *tx;
    for (id item in self.transactions) {
        tx = [MKMHistoryTransaction transactionWithTransaction:item];
        prevSign = tx.previousSignature;
        if (prevSign) {
            break;
        }
    }
    NSAssert(prevSign, @"not link yet");
    return prevSign;
}

@end
