//
//  MKMHistory.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPrivateKey.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"

#import "MKMHistory.h"

@interface MKMHistoryRecord()

@property (strong, nonatomic) const NSMutableArray *events;
@property (strong, nonatomic) const NSData *merkleRoot;
@property (strong, nonatomic) const NSData *signature;

@end

static NSData *link_merkle(const NSData *merkle, const NSData *prev) {
    if (!prev) {
        prev = merkle;
    }
    
    NSData *left = [merkle copy];
    NSData *right = [prev copy];
    
    NSUInteger len = [left length] + [right length];
    NSMutableData *mData = [NSMutableData dataWithCapacity:len];
    [mData appendData:left];
    [mData appendData:right];
    return mData;
}

@implementation MKMHistoryRecord

- (instancetype)init {
    if (self = [super init]) {
        _events = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    NSArray *events = [otherDictionary objectForKey:@"events"];
    NSAssert(events, @"history record error");
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:[events count]];
    for (id event in events) {
        if ([event isKindOfClass:[NSDictionary class]]) {
            [mArray addObject:[event jsonString]];
        } else {
            [mArray addObject:event];
        }
    }
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:otherDictionary];
    [mDict setObject:mArray forKey:@"events"];
    
    if (self = [super initWithDictionary:mDict]) {
        NSString *merkle = [mDict objectForKey:@"merkle"];
        NSString *signature = [mDict objectForKey:@"signature"];
        NSData *hash = [merkle base64Decode];
        NSData *CT = [signature base64Decode];
        
        self.events = mArray;
        self.merkleRoot = hash;
        self.signature = CT;
    }
    return self;
}

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithHistoryInfo:(const NSDictionary *)info {
    NSDictionary *dict = [info copy];
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithEvents:(const NSArray *)events
                        merkle:(const NSData *)hash
                     signature:(const NSData *)CT {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mDict setObject:events forKey:@"events"];
    if (hash && CT) {
        [mDict setObject:[hash base64Encode] forKey:@"merkle"];
        [mDict setObject:[CT base64Encode] forKey:@"signature"];
    }
    self = [self initWithDictionary:mDict];
    return self;
}

- (id)copy {
    return [[MKMHistoryRecord alloc] initWithEvents:_events merkle:_merkleRoot signature:_signature];
}

- (const NSData *)merkleRoot {
    if (!_merkleRoot) {
        // TODO: calculate merkle root for events
        _merkleRoot = [[_events jsonData] md5];
        // FIXME: above is just for test, please implement it
        
        // clear for refresh
        _signature = nil;
        _storeDictionary = nil;
    }
    return _merkleRoot;
}

- (void)addEvent:(const MKMHistoryEvent *)event {
    [_events addObject:event];
    
    // clear for refresh
    _merkleRoot = nil;
    _signature = nil;
    _storeDictionary = nil;
}

- (NSData *)signWithPreviousMerkle:(const NSData *)prev
                          privateKey:(const MKMPrivateKey *)SK {
    // hash = merkle + prev
    const NSData *merkle = self.merkleRoot;
    merkle = link_merkle(merkle, prev);
    
    // sign(merkle, SK)
    NSData *signature = [SK sign:merkle];
    self.signature = signature;
    
    _storeDictionary = nil; // clear for refresh
    return signature;
}

- (BOOL)verifyWithPreviousMerkle:(const NSData *)prev
                       publicKey:(const MKMPublicKey *)PK {
    // hash = merkle + prev
    const NSData *merkle = self.merkleRoot;
    merkle = link_merkle(merkle, prev);
    
    // verify(merkle, signature, PK)
    BOOL correct = [PK verify:merkle signature:self.signature];
    
    return correct;
}

- (NSUInteger)count {
    if (!_storeDictionary) {
        [self refresh];
    }
    return [_storeDictionary count];
}

- (id)objectForKey:(id)aKey {
    if (!_storeDictionary) {
        [self refresh];
    }
    return [_storeDictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    if (!_storeDictionary) {
        [self refresh];
    }
    return [_storeDictionary keyEnumerator];
}

- (BOOL)refresh {
    NSAssert([_events count] > 0, @"events cannot be empty");
    NSAssert(_merkleRoot, @"merkle root cannot be empty");
    NSAssert(_signature, @"signature cannot be empty");
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[_events count]];
    for (id event in _events) {
        if ([event isKindOfClass:[MKMHistoryEvent class]]) {
            [mArray addObject:[event jsonString]];
        } else {
            [mArray addObject:event];
        }
    }
    
    NSString *hash = [_merkleRoot base64Encode];
    NSString *CT = [_signature base64Encode];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [mDict setObject:mArray forKey:@"events"];
    [mDict setObject:hash forKey:@"merkle"];
    [mDict setObject:CT forKey:@"signature"];
    
    _storeDictionary = mDict;
    return YES;
}

@end

@interface MKMHistory ()

@end

@implementation MKMHistory

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSArray *array = [data jsonArray];
    self = [self initWithArray:array];
    return self;
}

- (id)copy {
    return [[MKMHistory alloc] initWithArray:_storeArray];
}

- (id)mutableCopy {
    return [self copy];
}

@end
