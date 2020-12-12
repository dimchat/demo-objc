// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  dimMacros.h
//  DIMCore
//
//  Created by Albert Moky on 2018/12/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef dimMacros_h
#define dimMacros_h

#import <MingKeMing/MingKeMing.h>

// Cryptography
#define DIMEncryptKey                   id<MKMEncryptKey>
#define DIMDecryptKey                   id<MKMDecryptKey>
#define DIMSignKey                      id<MKMSignKey>
#define DIMVerifyKey                    id<MKMVerifyKey>

#define DIMSymmetricKey                 id<MKMSymmetricKey>
#define DIMPublicKey                    id<MKMPublicKey>
#define DIMPrivateKey                   id<MKMPrivateKey>

// Entity
#define DIMID                           id<MKMID>
#define DIMAddress                      id<MKMAddress>
#define DIMMeta                         id<MKMMeta>
#define DIMDocument                     id<MKMDocument>
#define DIMEntity                       MKMEntity *
#define DIMEntityDataSource             id<MKMEntityDataSource>

// User
#define DIMUser                         MKMUser *
#define DIMUserDataSource               id<MKMUserDataSource>

// Group
#define DIMGroup                        MKMGroup *
#define DIMGroupDataSource              id<MKMGroupDataSource>

#import <DaoKeDao/DaoKeDao.h>

#define DIMEnvelope                     id<DKDEnvelope>
#define DIMContent                      id<DKDContent>

// Message
#define DIMMessage                      id<DKDMessage>
#define DIMInstantMessage               id<DKDInstantMessage>
#define DIMSecureMessage                id<DKDSecureMessage>
#define DIMReliableMessage              id<DKDReliableMessage>

#define DIMMessageDelegate              id<DKDMessageDelegate>
#define DIMInstantMessageDelegate       id<DKDInstantMessageDelegate>
#define DIMSecureMessageDelegate        id<DKDSecureMessageDelegate>
#define DIMReliableMessageDelegate      id<DKDReliableMessageDelegate>

#endif /* dimMacros_h */
