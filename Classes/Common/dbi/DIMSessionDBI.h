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
//  DIMClient
//
//  Created by Albert Moky on 2023/3/3.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>

#import <DIMClient/DIMLoginCommand.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

id<MKMID> DIMGSP(void);  // "gsp@everywhere"

#ifdef __cplusplus
} /* end of extern "C" */
#endif

@interface DIMProviderInfo : NSObject

@property (strong, nonatomic, readonly) id<MKMID> ID;
@property (nonatomic) NSInteger chosen;

- (instancetype)initWithID:(id<MKMID>)PID chosen:(NSInteger)order;

+ (instancetype)providerWithID:(id<MKMID>)PID chosen:(NSInteger)order;

+ (NSArray<DIMProviderInfo *> *)convert:(NSArray<NSDictionary *> *)array;

+ (NSArray<NSDictionary *> *)revert:(NSArray<DIMProviderInfo *> *)providers;

@end

@interface DIMStationInfo : NSObject

@property (strong, nonatomic) id<MKMID> ID;
@property (nonatomic) NSInteger chosen;

@property (strong, nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) UInt16 port;

@property (strong, nonatomic, nullable) id<MKMID> provider;

- (instancetype)initWithID:(nullable id<MKMID>)SID
                    chosen:(NSInteger)order
                      host:(NSString *)IP
                      port:(UInt16)port
                  provider:(nullable id<MKMID>)PID;

+ (instancetype)stationWithID:(nullable id<MKMID>)SID
                       chosen:(NSInteger)order
                         host:(NSString *)IP
                         port:(UInt16)port
                     provider:(nullable id<MKMID>)PID;

+ (NSArray<DIMStationInfo *> *)convert:(NSArray<NSDictionary *> *)array;

+ (NSArray<NSDictionary *> *)revert:(NSArray<DIMStationInfo *> *)stations;

@end

#pragma mark -

@protocol DIMProviderDBI <NSObject>

- (NSArray<DIMProviderInfo *> *)allProviders;

- (BOOL)addProvider:(id<MKMID>)PID chosen:(NSInteger)order;

- (BOOL)updateProvider:(id<MKMID>)PID chosen:(NSInteger)order;

- (BOOL)removeProvider:(id<MKMID>)PID;

@end

@protocol DIMStationDBI <NSObject>

- (NSArray<DIMStationInfo *> *)allStations:(id<MKMID>)PID;

- (BOOL)addStation:(id<MKMID>)SID
            chosen:(NSInteger)order
              host:(NSString *)IP
              port:(UInt16)port
          provider:(id<MKMID>)PID;

- (BOOL)updateStation:(id<MKMID>)SID
               chosen:(NSInteger)order
                 host:(NSString *)IP
                 port:(UInt16)port
             provider:(id<MKMID>)PID;

- (BOOL)removeStationWithHost:(NSString *)IP
                         port:(UInt16)port
                     provider:(id<MKMID>)PID;

- (BOOL)removeAllStations:(id<MKMID>)PID;

@end

typedef OKPair<id<DKDLoginCommand>, id<DKDReliableMessage>> DIMLoginCmdMsg;

@protocol DIMLoginDBI <NSObject>

/**
 *  Get login command & message
 *
 * @param user - login user ID
 * @return DKDLoginCommand & DKDReliableMessage
 */
- (DIMLoginCmdMsg *)loginCommandMessageForID:(id<MKMID>)user;

- (BOOL)saveLoginCommand:(id<DKDLoginCommand>)cmd
             withMessage:(id<DKDReliableMessage>)msg
                   forID:(id<MKMID>)user;

@end

@protocol DIMSessionDBI <DIMLoginDBI, DIMProviderDBI, DIMStationDBI>

@end

NS_ASSUME_NONNULL_END
