// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMAddressBTC.h
//  DIMPlugins
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

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
typedef NS_ENUM(UInt8, MKMBTCNetworkID) {
    MKMNetwork_BTCMain = 0x00, // 0000 0000
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
    MKMNetwork_Provider   = 0x76, // 0111 0110 (Service Provider)
    MKMNetwork_Station    = 0x88, // 1000 1000 (Server Node)
    
    //MKMNetwork_BotGroup = 0x74, // 0111 0100 (Content Provider)
    MKMNetwork_Bot        = 0xC8, // 1100 1000
    MKMNetwork_Thing      = 0x80, // 1000 0000 (IoT)
};
typedef UInt8 MKMNetworkType;

// Network ID
#define MKMNetwork_IsPerson(network)   (((network) == MKMNetwork_Main) ||      \
                                       ((network) == MKMNetwork_BTCMain))

#define MKMNetwork_IsStation(network)  ((network) == MKMNetwork_Station)
#define MKMNetwork_IsProvider(network) ((network) == MKMNetwork_Provider)

#define MKMNetwork_IsThing(network)    ((network) & MKMNetwork_Thing)
#define MKMNetwork_IsBot(network)      ((network) == MKMNetwork_Bot)

#ifdef __cplusplus
extern "C" {
#endif

MKMEntityType MKMEntityTypeFromNetworkID(MKMNetworkType network);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
