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
 *      MKMNetwork_Group indicates this entity is a group of people,
 *      which should have a founder (also the owner), and some members.
 *
 *      MKMNetwork_Moments indicates a special personal social network,
 *      where the owner can share informations and interact with its friends.
 *      The owner is the king here, it can do anything and no one can stop it.
 *
 *      MKMNetwork_Polylogue indicates a virtual (temporary) social network.
 *      It's created to talk with multi-people (but not too much, e.g. < 100).
 *      Any member can invite people in, but only the founder can expel member.
 *
 *      MKMNetwork_Chatroom indicates a massive (persistent) social network.
 *      It's usually more than 100 people in it, so we need administrators
 *      to help the owner to manage the group.
 *
 *      MKMNetwork_SocialEntity indicates this entity is a social entity.
 *
 *      MKMNetwork_Organization indicates an independent organization.
 *
 *      MKMNetwork_Company indicates this entity is a company.
 *
 *      MKMNetwork_School indicates this entity is a school.
 *
 *      MKMNetwork_Government indicates this entity is a government department.
 *
 *      MKMNetwork_Department indicates this entity is a department.
 *
 *      MKMNetwork_Thing this is reserved for IoT (Internet of Things).
 *
 *  Bits:
 *      0000 0001 - this entity's branch is independent (clear division).
 *      0000 0010 - this entity can contains other group (big organization).
 *      0000 0100 - this entity is top organization.
 *      0000 1000 - (Main) this entity acts like a human.
 *
 *      0001 0000 - this entity contains members (Group)
 *      0010 0000 - this entity needs other administrators (big organization)
 *      0100 0000 - this is an entity in reality.
 *      1000 0000 - (IoT) this entity is a 'Thing'.
 *
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, MKMNetworkID) {
    // Network_BTCMain = 0x00, // 0000 0000
    // Network_BTCTest = 0x6f, // 0110 1111
    
    /**
     *  Person Account
     */
    MKMNetwork_Main    = 0x08, // 0000 1000 (Person)
    
    /**
     *  Virtual Groups
     */
    MKMNetwork_Group   = 0x10, // 0001 0000 (Multi-Persons)
    
    //MKMNetwork_Moments = 0x18, // 0001 1000 (Twitter)
    MKMNetwork_Polylogue = 0x10, // 0001 0000 (Multi-Persons Chat, N < 100)
    MKMNetwork_Chatroom  = 0x30, // 0011 0000 (Multi-Persons Chat, N >= 100)
    
    /**
     *  Social Entities in Reality
     */
    //MKMNetwork_SocialEntity = 0x50, // 0101 0000
    
    //MKMNetwork_Organization = 0x74, // 0111 0100
    //MKMNetwork_Company      = 0x76, // 0111 0110
    //MKMNetwork_School       = 0x77, // 0111 0111
    //MKMNetwork_Government   = 0x73, // 0111 0011
    //MKMNetwork_Department   = 0x52, // 0101 0010
    
    /**
     *  Network
     */
    MKMNetwork_Provider  = 0x76, // 0111 0110 (Service Provider)
    MKMNetwork_Station   = 0x88, // 1000 1000 (Server Node)
    
    /**
     *  Internet of Things
     */
    MKMNetwork_Thing   = 0x80, // 1000 0000 (IoT)
    MKMNetwork_Robot   = 0xC8, // 1100 1000
};
typedef UInt8 MKMNetworkType;

#define MKMNetwork_IsCommunicator(network) ((network) & MKMNetwork_Main)

#define MKMNetwork_IsPerson(network)       ((network) == MKMNetwork_Main)
#define MKMNetwork_IsGroup(network)        ((network) & MKMNetwork_Group)

#define MKMNetwork_IsStation(network)      ((network) == MKMNetwork_Station)
#define MKMNetwork_IsProvider(network)     ((network) == MKMNetwork_Provider)

#define MKMNetwork_IsThing(network)        ((network) & MKMNetwork_Thing)
#define MKMNetwork_IsRobot(network)        ((network) == MKMNetwork_Robot)

/**
 *  Address like BitCoin
 *
 *      data format: "network+digest+checkcode"
 *          network    --  1 byte
 *          digest     -- 20 bytes
 *          check_code --  4 bytes
 *
 *      algorithm:
 *          fingerprint = sign(seed, SK);
 *          digest      = ripemd160(sha256(fingerprint));
 *          check_code  = sha256(sha256(network + digest)).prefix(4);
 *          address     = base58_encode(network + digest + check_code);
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
