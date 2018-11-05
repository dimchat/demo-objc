//
//  MKMHistoryTransaction.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMHistoryOperation;

/**
 *  history.records[i].events[j]
 *
 *      data format: {
 *          operation: "{...}",
 *          commander: "moky@address", // user ID
 *          signature: "..." // algorithm defined by version
 *      }
 */
@interface MKMHistoryTransaction : MKMDictionary

@property (readonly, strong, nonatomic) MKMHistoryOperation *operation;
@property (readonly, strong, nonatomic) MKMID *commander;
@property (readonly, strong, nonatomic) NSData *signature;

+ (instancetype)transactionWithTransaction:(id)event;

/**
 Copy history event from a dictioanry
 
 @param dict - data from database/network
 @return Operation
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Initialize an operation without signature,
 while the commander is the recorder

 @param op - operation object
 @return Event object
 */
- (instancetype)initWithOperation:(const MKMHistoryOperation *)op;

/**
 Initialize an operation with signature
 
 @param operation - JsON string of an operation
 @param ID - commander ID
 @param CT - signature
 @return Event object
 */
- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const MKMID *)ID
                        signature:(const NSData *)CT;

@end

#pragma mark - Link Transaction

@interface MKMHistoryTransaction (Link)

@property (readonly, strong, nonatomic) NSData *previousSignature;

@end

NS_ASSUME_NONNULL_END
