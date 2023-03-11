// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMSessionDBI.h
//  DIMP
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>

#import <DIMP/DIMLoginCommand.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMLoginDBI <NSObject>

/**
 *  Get login command & message
 *
 * @param user - login user ID
 * @return DKDLoginCommand & DKDReliableMessage
 */
- (OKPair<id<DKDLoginCommand>, id<DKDReliableMessage>> *)loginCommandMessageForID:(id<MKMID>)user;

- (BOOL)saveLoginCommand:(id<DKDLoginCommand>)cmd withMessage:(id<DKDReliableMessage>)msg forID:(id<MKMID>)user;

@end

@interface DIMStationParams : NSObject

@property(nonatomic, readonly) NSString  *host;
@property(nonatomic, readonly) NSUInteger port;
@property(nonatomic, readonly) id<MKMID>  ID;

- (instancetype)initWithID:(id<MKMID>)ID host:(NSString *)ip port:(NSUInteger)port;

@end

@protocol DIMProviderDBI <NSObject>

- (NSSet<DIMStationParams *> *)neighborStations;

- (DIMStationParams *)stationWithHost:(NSString *)ip port:(NSUInteger)port;

- (BOOL)addStationWithID:(id<MKMID>)ID host:(NSString *)ip port:(NSUInteger)port;
- (BOOL)removeStationWithHost:(NSString *)ip port:(NSUInteger)port;

@end

@protocol DIMSessionDBI <DIMLoginDBI, DIMProviderDBI>

@end

NS_ASSUME_NONNULL_END
