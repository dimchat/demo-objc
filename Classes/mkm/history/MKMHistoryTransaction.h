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
@class MKMAddress;
@class MKMHistoryOperation;

typedef NSDictionary<const MKMAddress *, NSString *> MKMConfirmTable;

/**
 *  history.records[i].events[j]
 *
 *      data format: {
 *          operation: "{...}",
 *          commander: "...",   // account ID
 *          signature: "...",   // algorithm defined by version
 *          //-- confirmed by members
 *          confirmations: {"address":"CT", }, // CT = sign(cmderSig, memberSK)
 *      }
 */
@interface MKMHistoryTransaction : MKMDictionary

@property (readonly, strong, nonatomic) MKMHistoryOperation *operation;

@property (readonly, strong, nonatomic) MKMID *commander;
@property (readonly, strong, nonatomic) NSData *signature;

/**
 NOTICE: The history recorder must collect more than 50% confirmations
 from members before packing a HistoryBlock for a group.
 */
@property (readonly, strong, nonatomic) MKMConfirmTable *confirmations;

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

/**
 Add confirmation of member

 @param CT - confirmation = sign(commander.signature, member.SK)
 @param ID - member ID
 */
- (void)setConfirmation:(const NSData *)CT forID:(const MKMID *)ID;

/**
 Get confirmation by member ID

 @param ID - member ID
 @return confirmation of the signature
 */
- (NSData *)confirmationForID:(const MKMID *)ID;

@end

#pragma mark - Link Transaction

@interface MKMHistoryTransaction (Link)

@property (readonly, strong, nonatomic) NSData *previousSignature;

@end

NS_ASSUME_NONNULL_END
