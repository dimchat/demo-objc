//
//  MKMAddress.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMString.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMAddressDefaultVersion 0x01

/**
 *  @enum MKMNetworkID
 *
 *  @abstract A network type to indicate what kind the entity is.
 *
 *  @discussion An address can identify a person, a group of people,
 *      a team, even a thing.
 *
 *      MKMNetwork_Main indicates this entity is a person's account.
 *      An account should have a public key, which proved by meta data.
 *
 *      MKMNetwork_Polylogue indicates a virtual (temporary) social network.
 *      It's created to talk with multi-people (but not too much, e.g. < 100).
 *      Any member can invite people in, but only the founder can expel member.
 *
 *      MKMNetwork_Moments indicates a special personal social network,
 *      where the owner can share informations and interact with its friends.
 *      The owner is the king here, it can do anything and no one can stop it.
 *
 *      MKMNetwork_Social indicates this entity is a social entity.
 *      A social entity should have a founder, an owner, and some members.
 *
 *      MKMNetwork_Group indicates this entity is a persistent group.
 *      A group should have a founder, an owner, some members, and some
 *      administrators if need.
 *
 *      MKMNetwork_Company indicates this entity is a company.
 *
 *      MKMNetwork_Department indicates this entity is a department.
 *
 *      MKMNetwork_School indicates this entity is a school.
 *
 *      MKMNetwork_Government indicates this entity is a government department.
 *
 *      MKMNetwork_Thing this is reserved for IoT (Internet of Things).
 *
 *  Bits:
 *      0000 0001 - this entity's branch is self-governing (big organization).
 *      0000 0010 - this entity has branch usually (contains other group).
 *      0000 0100 - this entity is top organization.
 *      0000 1000 - (Main) this entity acts like a person.
 *      0001 0000 - (Group) this entity has founder, who create the entity.
 *      0010 0000 - (Group) this entity has owner, which can abdicate.
 *      0100 0000 - (IoT) this entity is a thing.
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, MKMNetworkID) {
    // Network_BTCMain = 0x00, // 0000 0000
    // Network_BTCTest = 0x6f, // 0110 1111
    
    MKMNetwork_Main    = 0x08, // 0000 1000 (Person)
    
    MKMNetwork_Polylogue = 0x10, // 0001 0000 (Multi-Persons Chat, N < 100)
    //MKMNetwork_Moments = 0x18, // 0001 1000 (Twitter)
    MKMNetwork_Official  = 0x38, // 0011 1000 (Official Account)
    
    //MKMNetwork_Social  = 0x30, // 0011 0000
    MKMNetwork_Group     = 0x34, // 0011 0100 (Multi-Persons Chat, N >= 100)
    
    //MKMNetwork_Company    = 0x36, // 0011 0110
    //MKMNetwork_School     = 0x37, // 0011 0111
    //MKMNetwork_Department = 0x32, // 0011 0010
    //MKMNetwork_Government = 0x33, // 0011 0011
    
    //MKMNetwork_Thing      = 0x60, // 0110 0000 (IoT)
};
typedef UInt8 MKMNetworkType;

/**
 *  Address like BitCoin
 *
 *      data format: "network+hash+checkcode"
 *          network   -- 1 byte
 *          hash      -- 20 bytes
 *          checkcode -- 4 bytes
 *
 *      algorithm:
 *          CT   = sign(seed, SK);
 *          hash = ripemd160(sha256(CT));
 *          code = sha256(sha256(network+hash)).prefix(4)
 *          addr = base58(network+hash+check)
 */
@interface MKMAddress : MKMString

@property (readonly, nonatomic) MKMNetworkType network; // Network ID
@property (readonly, nonatomic) UInt32 code;            // Check Code

@property (readonly, nonatomic, getter=isValid) BOOL valid;

+ (instancetype)addressWithAddress:(id)addr;

/**
 Copy address data

 @param aString - Encoded address string
 @return Address object
 */
- (instancetype)initWithString:(NSString *)aString;

/**
 Generate address with fingerprint and network ID

 @param CT - fingerprint = sign(seed, PK)
 @param type - network ID
 @param metaVersion - algorithm version
 @return Address object
 */
- (instancetype)initWithFingerprint:(const NSData *)CT
                            network:(MKMNetworkType)type
                            version:(NSUInteger)metaVersion;

@end

NS_ASSUME_NONNULL_END
