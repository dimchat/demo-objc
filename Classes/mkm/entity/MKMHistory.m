//
//  MKMHistory.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"
#import "NSArray+Merkle.h"

#import "MKMPrivateKey.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMHistoryEvent.h"

#import "MKMEntityManager.h"

#import "MKMHistory.h"

static NSData *link_merkle(const NSData *merkle, const NSData *prev) {
    assert(merkle);
    if (!prev) {
        return [merkle copy];
    }
    
    NSData *left = [prev copy];
    NSData *right = [merkle copy];
    
    NSUInteger len = [left length] + [right length];
    NSMutableData *mData = [NSMutableData dataWithCapacity:len];
    [mData appendData:left];
    [mData appendData:right];
    return [mData sha256];
}

static NSMutableArray *copy_events(const NSArray *events) {
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

@interface MKMHistoryRecord ()

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSData *merkleRoot;
@property (strong, nonatomic) NSData *signature;
@property (strong, nonatomic) MKMID *recorder;

@end

@implementation MKMHistoryRecord

+ (instancetype)recordWithRecord:(id)record {
    if ([record isKindOfClass:[MKMHistoryRecord class]]) {
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
        _events = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        id events = [dict objectForKey:@"events"];
        NSString *merkle = [dict objectForKey:@"merkle"];
        NSString *signature = [dict objectForKey:@"signature"];
        NSString *recorder = [dict objectForKey:@"recorder"];
        
        if (merkle || signature) {
            NSMutableDictionary *mDict = [dict mutableCopy];
            events = copy_events(events);
            NSAssert([events count] > 0, @"history record error");
            [mDict setObject:events forKey:@"events"];
            dict = mDict;
        } else {
            events = [[NSMutableArray alloc] initWithArray:events];
        }
        
        _events = events;
        _merkleRoot = [merkle base64Decode];
        _signature = [signature base64Decode];
        _recorder = [MKMID IDWithID:recorder];
    }
    return self;
}

- (instancetype)initWithEvents:(const NSArray *)events
                        merkle:(const NSData *)hash
                     signature:(const NSData *)CT {
    MKMID *ID = nil;
    self = [self initWithEvents:events
                         merkle:hash
                      signature:CT
                       recorder:ID];
    return self;
}

- (instancetype)initWithEvents:(const NSArray *)events
                        merkle:(const NSData *)hash
                     signature:(const NSData *)CT
                      recorder:(nullable const MKMID *)ID {
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSMutableArray *mArray;
    if (hash && CT) {
        [mDict setObject:[hash base64Encode] forKey:@"merkle"];
        [mDict setObject:[CT base64Encode] forKey:@"signature"];
        if (ID) {
            [mDict setObject:ID forKey:@"recorder"];
        }
        mArray = copy_events(events);
    } else {
        mArray = [events mutableCopy];
    }
    NSAssert([mArray count] > 0, @"events error");
    [mDict setObject:mArray forKey:@"events"];

    if (self = [super initWithDictionary:mDict]) {
        _events = mArray;
        _merkleRoot = [hash copy];
        _signature = [CT copy];
        _recorder = [ID copy];
    }
    
    return self;
}

- (NSData *)merkleRoot {
    if (!_merkleRoot) {
        // calculate merkle root for events
        NSArray *events = copy_events(_events);
        _merkleRoot = [events merkleRoot];
        
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
    if (_recorder) {
        // make sure the recorder's PK is match with this SK
        MKMEntityManager *eman = [MKMEntityManager sharedInstance];
        MKMPublicKey *PK = [eman metaForID:_recorder].key;
        if (![PK isMatch:SK]) {
            NSAssert(false, @"keys not match");
            return nil;
        }
    }
    
    // hash = prev + merkle
    NSData *merkle = self.merkleRoot;
    merkle = link_merkle(merkle, prev);
    
    // sign(hash, SK)
    NSData *signature = [SK sign:merkle];
    self.signature = signature;
    
    _storeDictionary = nil; // clear for refresh
    return signature;
}

- (BOOL)verifyWithPreviousMerkle:(const NSData *)prev
                       publicKey:(const MKMPublicKey *)PK {
    if (_recorder) {
        // make sure the recorder's PK is match with this PK
        MKMEntityManager *eman = [MKMEntityManager sharedInstance];
        MKMPublicKey *PK2 = [eman metaForID:_recorder].key;
        if (![PK isEqual:PK2]) {
            NSAssert(false, @"keys not equal");
            return nil;
        }
    }
    
    // hash = prev + merkle
    NSData *merkle = self.merkleRoot;
    merkle = link_merkle(merkle, prev);
    // verify(hash, signature, PK)
    return [PK verify:merkle signature:self.signature];
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
    
    NSArray *array = copy_events(_events);
    NSString *hash = [_merkleRoot base64Encode];
    NSString *CT = [_signature base64Encode];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [mDict setObject:array forKey:@"events"];
    [mDict setObject:hash forKey:@"merkle"];
    [mDict setObject:CT forKey:@"signature"];
    
    _storeDictionary = mDict;
    return YES;
}

@end

@interface MKMHistory ()

@end

@implementation MKMHistory

+ (instancetype)historyWithHistory:(id)history {
    if ([history isKindOfClass:[MKMHistory class]]) {
        return history;
    } else if ([history isKindOfClass:[NSArray class]]) {
        return [[self alloc] initWithArray:history];
    } else if ([history isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:history];
    } else {
        NSAssert(!history, @"unexpected history: %@", history);
        return nil;
    }
}

@end
