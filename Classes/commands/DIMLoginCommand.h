// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMLoginCommand.h
//  DIMSDK
//
//  Created by Albert Moky on 2020/4/14.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMCommand_Login     @"login"

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      cmd      : "login",
 *      time     : 0,
 *      //---- client info ----
 *      ID       : "{UserID}",
 *      device   : "DeviceID",  // (optional)
 *      agent    : "UserAgent", // (optional)
 *      //---- server info ----
 *      station  : {
 *          ID   : "{StationID}",
 *          host : "{IP}",
 *          port : 9394
 *      },
 *      provider : {
 *          ID   : "{SP_ID}"
 *      }
 *  }
 */
@protocol DIMLoginCommand <DIMCommand>

#pragma mark Client Info

// User ID
@property (readonly, strong, nonatomic) id<MKMID> ID;
// Device ID
@property (strong, nonatomic, nullable) NSString *device;
// User-Agent
@property (strong, nonatomic, nullable) NSString *agent;

#pragma mark Server Info

// station
@property (strong, nonatomic) NSDictionary *stationInfo;
// SP
@property (strong, nonatomic, nullable) NSDictionary *providerInfo;

@end

@interface DIMLoginCommand : DIMCommand <DIMLoginCommand>

- (instancetype)initWithID:(id<MKMID>)ID;

- (void)copyStationInfo:(DIMStation *)station;
- (void)copyProviderInfo:(DIMServiceProvider *)provider;

@end

NS_ASSUME_NONNULL_END
