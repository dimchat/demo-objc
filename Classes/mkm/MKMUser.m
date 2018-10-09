//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"
#import "MKMKeyStore.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"
#import "MKMProfile.h"
#import "MKMContact.h"

#import "MKMHistoryEvent.h"
#import "MKMHistory.h"

#import "MKMEntity+History.h"
#import "MKMEntityManager.h"

#import "MKMAccountHistoryDelegate.h"

#import "MKMUser.h"

@interface MKMUser ()

@property (strong, nonatomic) const MKMPrivateKey *privateKey;

@end

@implementation MKMUser

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _contacts = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)addContact:(MKMContact *)contact {
    if (contact.ID.isValid == NO) {
        // ID error
        return NO;
    }
    if (contact.status != MKMAccountStatusRegistered) {
        // status error
        return NO;
    }
    
    [_contacts setObject:contact forKey:contact.ID];
    return YES;
}

- (MKMContact *)getContactByID:(const MKMID *)ID {
    return [_contacts objectForKey:ID];
}

- (const MKMPrivateKey *)privateKey {
    if (!_privateKey) {
        MKMKeyStore *store = [MKMKeyStore sharedStore];
        const MKMPrivateKey *SK = [store privateKeyForUser:self];
        if ([self checkPrivateKey:SK]) {
            //_privateKey = [SK copy];
        }
    }
    return _privateKey;
}

- (BOOL)checkPrivateKey:(const MKMPrivateKey *)SK {
    BOOL correct = [self.publicKey isMatch:SK];
    if (correct) {
        self.privateKey = SK;
    }
    return correct;
}

@end

@implementation MKMUser (History)

+ (instancetype)registerWithName:(const NSString *)seed
                       publicKey:(const MKMPublicKey *)PK
                      privateKey:(const MKMPrivateKey *)SK {
    NSAssert([seed length] > 2, @"seed error");
    NSAssert([PK isMatch:SK], @"PK must match SK");
    
    // 1. generate meta
    MKMMeta *meta;
    meta = [[MKMMeta alloc] initWithSeed:seed publicKey:PK privateKey:SK];
    NSLog(@"register meta: %@", meta);
    
    MKMAddress *address;
    address = [[MKMAddress alloc] initWithFingerprint:meta.fingerprint
                                              network:MKMNetwork_Main
                                              version:MKMAddressDefaultVersion];
    
    // 2. generate ID
    MKMID *ID = [[MKMID alloc] initWithName:seed address:address];
    NSLog(@"register ID: %@", ID);
    
    // 3. generate history
    MKMHistory *history;
    MKMHistoryRecord *his;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    op = [[MKMHistoryOperation alloc] initWithOperate:@"register"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    his = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [his signWithPreviousMerkle:hash privateKey:SK];
    NSArray *records = [NSArray arrayWithObject:his];
    history = [[MKMHistory alloc] initWithArray:records];
    NSLog(@"register history: %@", history);
    
    // 4. create
    MKMAccountHistoryDelegate *delegate;
    delegate = [[MKMAccountHistoryDelegate alloc] init];
    MKMUser *user = [[self alloc] initWithID:ID meta:meta];
    user.historyDelegate = delegate;
    NSInteger count = [user runHistory:history];
    NSAssert([history count] == count, @"history error");
    
    // 5. send the ID+meta+history out
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    BOOL OK = [em setMeta:meta history:history forID:ID];
    NSAssert(OK, @"error");
    
    return user;
}

- (MKMHistoryRecord *)suicideWithMessage:(const NSString *)lastWords
                              privateKey:(const MKMPrivateKey *)SK {
    NSAssert([_ID.publicKey isMatch:SK], @"not your SK");
    
    // 1. generate history record
    MKMHistoryRecord *record;
    MKMHistoryEvent *evt;
    MKMHistoryOperation *op;
    op = [[MKMHistoryOperation alloc] initWithOperate:@"suicide"];
    evt = [[MKMHistoryEvent alloc] initWithOperation:op];
    NSArray *events = [NSArray arrayWithObject:evt];
    NSData *hash = nil;
    NSData *CT = nil;
    record = [[MKMHistoryRecord alloc] initWithEvents:events merkle:hash signature:CT];
    [record signWithPreviousMerkle:hash privateKey:SK];
    NSLog(@"suicide record: %@", record);
    
    // 2. send the history record out
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    BOOL OK = [em addHistoryRecord:record forID:_ID];
    NSAssert(OK, @"error");
    
    return record;
}

@end
