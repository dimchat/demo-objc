//
//  MKMEntityHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMEntity.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMBarrack.h"

#import "MKMEntityHistoryDelegate.h"

@implementation MKMEntityHistoryDelegate

- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record {
    NSAssert([record.recorder isValid], @"recorder error");
    
    // hash(record.events)
    NSData *hash = record.merkleRoot;
    
    // signature
    NSData *CT = record.signature;
    NSAssert(CT, @"signature error");
    
    // check signature for this record
    MKMPublicKey *PK = MKMPublicKeyForID(record.recorder);
    if (![PK verify:hash withSignature:CT]) {
        NSAssert(false, @"signature error");
        return NO;
    }
    
    // let the subclass to define the permissions
    return YES;
}

- (BOOL)evolvingEntity:(const MKMEntity *)entity
           canRunEvent:(const MKMHistoryTransaction *)event
              recorder:(const MKMID *)recorder {
    NSAssert([recorder isValid], @"recorder error");
    
    if (event.commander == nil || [event.commander isEqual:recorder]) {
        // no need to verify signature when commander is the history recorder
        // and if event.commander not set, it means the recorder is commander
        NSAssert(event.signature == nil, @"event error");
        return YES;
    }
    NSAssert([event.commander isValid], @"commander error");
    
    // hash(operation)
    id op = event.operation;
    NSData *data;
    if ([op isKindOfClass:[NSString class]]) {
        data = [op data];
    } else {
        NSAssert(false, @"operation error");
        data = [op jsonData];
    }
    NSData *hash = [data sha256d];
    
    // signature
    NSData *CT = event.signature;
    NSAssert(CT, @"signature error");
    
    // check signature for this event
    MKMPublicKey *PK = MKMPublicKeyForID(event.commander);
    if (![PK verify:hash withSignature:CT]) {
        NSAssert(false, @"signature error");
        return NO;
    }
    
    // let the subclass to define the permissions
    return YES;
}

- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander {
    NSAssert([commander isValid], @"commander error");
    // let the subclass to do the operating
    return ;
}

@end
